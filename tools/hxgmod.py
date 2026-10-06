from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import uuid
from contextlib import contextmanager
from pathlib import Path

SDK_ROOT = Path(__file__).resolve().parents[1]
VERSION = json.loads((SDK_ROOT / 'haxelib.json').read_text(encoding='utf-8'))['version']
ASSET_DIRS = ('models', 'materials', 'sound', 'resource', 'particles', 'maps')
VERBOSE = False
NAME = re.compile(r'[a-z0-9][a-z0-9_-]*\Z')
MAIN = re.compile(r'(?:[a-z_][A-Za-z0-9_]*\.)*[A-Z][A-Za-z0-9_]*\Z')
MARKER = '.hxgmod-install.json'


@contextmanager
def staging_directory(parent, prefix='.hxgmod-'):
    # Inherit the parent ACL on Windows. Python 3.13+ TemporaryDirectory's
    # owner-only ACL excludes restricted-token build processes.
    parent = Path(parent)
    parent.mkdir(parents=True, exist_ok=True)
    path = parent / (prefix + uuid.uuid4().hex)
    path.mkdir()
    try:
        yield path
    finally:
        if path.exists():
            shutil.rmtree(path)


class HxGModError(RuntimeError):
    pass


def run(command, root, capture=False):
    if VERBOSE:
        print('[HxGMod] > ' + subprocess.list2cmdline(list(map(str, command))), flush=True)
    try:
        result = subprocess.run(command, cwd=root, text=True, capture_output=True)
    except FileNotFoundError as exc:
        raise HxGModError(f'{command[0]} is missing. Install it and reopen your terminal.') from exc
    if result.returncode:
        detail = (result.stderr or result.stdout).strip()
        raise HxGModError(f'{command[0]} failed ({result.returncode}):\n{detail}')
    if not capture and VERBOSE and result.stdout:
        print(result.stdout.rstrip())
    if not capture and result.stderr:
        print(result.stderr.rstrip(), file=sys.stderr)
    return result


def find_project_root(start=None):
    current = Path(start or Path.cwd()).resolve()
    if current.is_file():
        current = current.parent
    return next((p for p in (current, *current.parents) if (p / 'hxgmod.json').is_file()), None)


def require_project_root():
    root = find_project_root()
    if root is None:
        raise HxGModError('No hxgmod.json found. Enter a project or run hxgmod new addon NAME.')
    return root


def valid_name(value, label='name'):
    if not isinstance(value, str) or not NAME.fullmatch(value) or value.split('.')[0].upper() in {'CON', 'PRN', 'AUX', 'NUL', *(f'COM{i}' for i in range(1, 10)), *(f'LPT{i}' for i in range(1, 10))}:
        raise HxGModError(f'{label} must start with a lowercase letter or digit and use lowercase letters, digits, _ or - (no Windows device names).')
    return value


def load_config(root):
    try:
        config = json.loads((root / 'hxgmod.json').read_text(encoding='utf-8-sig'))
    except (OSError, ValueError) as exc:
        raise HxGModError(f'Cannot read hxgmod.json: {exc}') from exc
    if not isinstance(config, dict):
        raise HxGModError('hxgmod.json must be a JSON object.')
    config['name'] = valid_name(config.get('name', config.get('addon_name')), 'Project name')
    if config.get('project_type', 'addon') not in ('addon', 'gamemode'):
        raise HxGModError('project_type must be addon or gamemode.')
    config.setdefault('project_type', 'addon')
    if config.get('source_layout', 'legacy') not in ('legacy', 'filesystem'):
        raise HxGModError('source_layout must be filesystem or legacy.')
    if mirrored(config) and any(config.get(k) for k in ('entities', 'weapons')):
        raise HxGModError('Filesystem projects use mirrored entity/weapon paths; remove configured targets. See docs/filesystem.md.')
    if not isinstance(config.get('install_path', ''), str):
        raise HxGModError('install_path must be a string.')
    gm = config.get('gamemode', {})
    if not isinstance(gm, dict):
        raise HxGModError('gamemode must be an object.')
    for key, value in gm.items():
        if not isinstance(value, str) or any(ord(c) < 32 for c in value):
            raise HxGModError(f'gamemode.{key} must be a string without control characters.')
    for kind in ('entities', 'weapons'):
        entries = config.get(kind, {})
        if not isinstance(entries, dict):
            raise HxGModError(f'{kind} must map GMod class names to Haxe main classes.')
        for name, main in entries.items():
            valid_name(name, f'{kind} class name')
            if not isinstance(main, str) or not MAIN.fullmatch(main):
                raise HxGModError(f'{kind}.{name} must be a Haxe class such as shared.LearningEntity.')
    return config


def save_config(root, config):
    (root / 'hxgmod.json').write_text(json.dumps(config, indent=2) + '\n', encoding='utf-8')


def safe_dir(root, relative):
    """Output trees must not escape a project through a junction or symlink."""
    root = root.resolve()
    path = root / relative
    resolved = path.resolve()
    if resolved == root or not resolved.is_relative_to(root):
        raise HxGModError(f'Unsafe output path: {path}')
    if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
        raise HxGModError(f'Output path is a link: {path}')
    return path


def delete_output(root, relative):
    target = safe_dir(root, relative)
    if target.exists():
        shutil.rmtree(target)


def compiler_flags(realm):
    return ['-D', 'lua-ver=5.1', '-D', 'luajit', '-D', 'lua-vanilla', '--dce', 'full',
            '-D', 'gmod_realm_strict', '-D', f'gmod_{realm}']


def build_hxml(realm):
    main = f'{realm}.{realm.title()}Main'
    return ('-lib hxgmod\n-cp src\n' + f'-main {main}\n--lua build/{realm}/hxgmod_{realm}.lua\n'
            + '-D lua-ver=5.1\n-D luajit\n-D lua-vanilla\n--dce full\n-D gmod_realm_strict\n' + f'-D gmod_{realm}\n')


def check_library(root=None):
    try:
        result = run(['haxelib', 'path', 'hxgmod'], root or SDK_ROOT, capture=True)
    except HxGModError as exc:
        raise HxGModError(f'{exc}\nRegister this SDK with "{SDK_ROOT / "hxgmod.bat"}" register, then retry.') from exc
    paths = [Path(p.strip()).resolve() for p in result.stdout.splitlines() if p.strip() and not p.startswith('-')]
    if (SDK_ROOT / 'src').resolve() not in paths:
        raise HxGModError(f'haxelib points to another SDK. Run "{SDK_ROOT / "hxgmod.bat"}" register.')


def mirrored(config):
    return config.get('source_layout', 'legacy') == 'filesystem'


def infer_realm(relative):
    parts = Path(relative).as_posix().lower().split('/')
    # Explicit directories win; conventional loader names cover special targets.
    if 'server' in parts[:-1]:
        return 'server'
    if 'client' in parts[:-1]:
        return 'client'
    if parts[-1] in ('init.hx', 'init.lua'):
        return 'server'
    if parts[-1] in ('cl_init.hx', 'cl_init.lua'):
        return 'client'
    return 'shared'


def source_files(folder):
    if folder.is_symlink() or (hasattr(folder, 'is_junction') and folder.is_junction()):
        raise HxGModError(f'Source trees must not contain links: {folder}')
    if folder.exists() and not folder.is_dir():
        raise HxGModError(f'Expected a directory: {folder}')
    for path in sorted(folder.rglob('*')):
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise HxGModError(f'Source trees must not contain links: {path}')
        if path.is_file():
            yield path


def validate_package_path(relative):
    parts = relative.split('/')
    for part in parts:
        if (not part or part in ('.', '..') or part[-1:] in (' ', '.')
                or any(ord(c) < 32 or c in '<>:"\\|?*' for c in part)
                or part.split('.')[0].upper() in {'CON', 'PRN', 'AUX', 'NUL',
                    *(f'COM{i}' for i in range(1, 10)), *(f'LPT{i}' for i in range(1, 10))}):
            raise HxGModError(f'Invalid package path: {relative}. Use portable folder/file names and forward slashes.')
    if relative.lower() == MARKER:
        raise HxGModError(f'Reserved package file: {relative}')


def raw_files(root, config):
    addon = config['project_type'] == 'addon'
    folders = [('lua', 'lua/' if addon else 'gamemode/'), ('package-root', '')]
    folders += [(name, ('' if addon else 'content/') + name + '/') for name in ASSET_DIRS]
    for directory, prefix in folders:
        for path in source_files(root / directory):
            relative = prefix + path.relative_to(root / directory).as_posix()
            validate_package_path(relative)
            yield path, relative


def mirror_plan(root, config):
    addon = config['project_type'] == 'addon'
    folder = root / ('src/lua' if addon else 'src/gamemode-root')
    if not folder.is_dir():
        raise HxGModError(f'Missing mirrored source root: {folder}')
    entries, raw, owners = [], [], {}

    def reserve(relative, owner):
        validate_package_path(relative)
        low = relative.lower()
        for existing in owners:
            if low == existing or low.startswith(existing + '/') or existing.startswith(low + '/'):
                raise HxGModError(f'Output path collision: {relative} ({owner}; {owners[existing]})')
        owners[low] = owner

    for path in source_files(folder):
        if path.suffix.lower() != '.hx':
            raise HxGModError(f'Only .hx entries belong in {folder}; move raw assets to lua/ or package-root/: {path}')
        relative = ('lua/' if addon else '') + path.relative_to(folder).with_suffix('.lua').as_posix()
        reserve(relative, path)
        entries.append((path, relative, infer_realm(relative)))
    if not entries:
        raise HxGModError(f'No mirrored .hx entries in {folder}')
    for path, relative in raw_files(root, config):
        reserve(relative, path)
        raw.append((path, relative))
    # File/folder definitions of a single entity or weapon are ambiguous to GMod.
    base = 'lua/' if addon else 'entities/'
    for kind in ('entities', 'weapons'):
        prefix = base + kind + '/'
        for relative in list(owners):
            if relative.startswith(prefix) and '/' not in relative[len(prefix):] and relative.endswith('.lua'):
                stem = relative[:-4] + '/'
                if any(other.startswith(stem) for other in owners):
                    raise HxGModError(f'Entity/weapon file and folder collision: {relative}')
    if addon:
        reserve(f'lua/autorun/server/{config["name"]}_hxgmod_transfer.lua', 'generated transfer list')
    else:
        reserve(config['name'] + '.txt', 'generated gamemode descriptor')
        for required in ('gamemode/init.lua', 'gamemode/cl_init.lua'):
            if required not in owners:
                raise HxGModError(f'Gamemode requires {required}; provide its mirrored .hx or raw Lua entry.')
    return entries, raw


def build_mirrored(root, config, realm):
    entries, _ = mirror_plan(root, config)
    folder = root / ('src/lua' if config['project_type'] == 'addon' else 'src/gamemode-root')
    modules = {}
    for source, relative, inferred in entries:
        path = source.relative_to(folder).with_suffix('')
        name = '.'.join(path.parts)
        text = re.sub(r'/\*.*?\*/|//[^\n]*', '', source.read_text(encoding='utf-8-sig'), flags=re.S)
        legacy = name != 'Main' and re.search(r'\bpackage\s*;', text) and re.search(r'\bclass\s+Main\b', text)
        if not MAIN.fullmatch(name) and not legacy:
            raise HxGModError(f'{source}: use a capitalized Haxe module filename and matching package (for example player/PlayerVar.hx, package player;). Conventional lowercase GMod loaders use package; class Main with static main().')
        if MAIN.fullmatch(name) and not legacy:
            declaration = re.search(r'^\s*package\s*([A-Za-z0-9_.]*)\s*;', text, re.M)
            expected = '.'.join(path.parts[:-1])
            if declaration and declaration.group(1) != expected:
                raise HxGModError(f'{source}: expected package {expected or "(root)"}; to match the mirrored path. Move the file or correct its package declaration.')
            modules[name] = {'path': relative, 'realm': inferred}
    if 'Main' in modules and len(modules) != len(entries):
        raise HxGModError('Root module Main conflicts with legacy Main loaders; put the named Main in a package.')
    namespace = hashlib.sha256((str(root.resolve()) + ':' + config['name']).encode()).hexdigest()[:24]
    graphs = {'server': {}, 'client': {}}
    with staging_directory(root / 'build', 'entry-') as stage:
        for source, relative, inferred in entries:
            name = '.'.join(source.relative_to(folder).with_suffix('').parts)
            named = name in modules
            realms = ('server', 'client') if inferred == 'shared' else (inferred,)
            for current in realms:
                if realm != 'all' and current != realm:
                    continue
                if not named:
                    shutil.copy2(source, stage / 'Main.hx')
                else:
                    (stage / 'Main.hx').unlink(missing_ok=True)
                out = safe_dir(root, f'build/mirror/{current}/{relative}')
                out.parent.mkdir(parents=True, exist_ok=True)
                spec = stage / 'link.json'
                manifest = stage / 'manifest.json'
                spec.write_text(json.dumps({'modules': modules, 'own': name if named else 'Main',
                    'realm': current, 'manifest': str(manifest)}), encoding='utf-8')
                print(f'[HxGMod] {source.relative_to(root)} ({current})')
                run(['haxe', '-lib', 'hxgmod', '-cp', str(root / 'src'), '-cp', str(folder), '-cp', str(stage),
                     *([name] if named else ['-main', 'Main']), '--lua', str(out), *compiler_flags(current),
                     '-D', 'hxgmod_link=' + str(spec), '--macro', 'hxgmod.ModuleLink.setup()'], root)
                data = json.loads(manifest.read_text(encoding='utf-8'))
                graphs[current][name] = sorted({i['module'] for i in data['imports']})
                content = linked_bundle(out.read_text(encoding='utf-8'), data, modules, name,
                                        namespace, config, current, named)
                out.write_text(content, encoding='utf-8')
    for current, graph in graphs.items():
        done, active = set(), []
        def visit(name):
            if name in active:
                raise HxGModError(f'Unsupported mirrored module cycle ({current}): ' + ' -> '.join(active + [name]) + '. Move shared dependencies into a third module to break the cycle.')
            if name in done:
                return
            active.append(name)
            for dependency in graph.get(name, []):
                visit(dependency)
            active.pop()
            done.add(name)
        for name in graph:
            visit(name)


def linked_bundle(bundle, data, modules, name, namespace, config, realm, named):
    """Inject bindings, never rewrite compiler-generated implementation text."""
    def virtual(module):
        path = modules[module]['path']
        if config['project_type'] == 'addon':
            return path[4:]
        return config['name'] + '/' + path
    prefix = ('local registry = rawget(_G, "__hxgmod_modules_v1")\n'
              'if not registry then registry = {}; rawset(_G, "__hxgmod_modules_v1", registry) end\n'
              f'local key = {quote(namespace + ":" + realm)}\n'
              'registry[key] = registry[key] or {}\nlocal project = registry[key]\n')
    if named:
        prefix += (f'local id = {quote(name)}\n'
                   'if project[id] then\n'
                   ' if project[id].loading then error("HxGMod module cycle: " .. id) end\n'
                   ' if project[id].failed then error(project[id].error) end\n'
                   ' return project[id].value\nend\n'
                   'project[id] = {loading = true}\n')
    bindings = ''
    for dependency in sorted({i['module'] for i in data['imports']}):
        bindings += (f'if not project[{quote(dependency)}] then include({quote(virtual(dependency))}) end\n'
                     f'local dependency = project[{quote(dependency)}]\n'
                     'if not dependency or dependency.loading or dependency.failed then error('
                     + quote('HxGMod dependency failed or cyclic: ' + dependency) + ') end\n')
        for item in data['imports']:
            if item['module'] == dependency:
                bindings += f'local {item["symbol"]} = dependency.value[{quote(item["symbol"])}]\n'
    exports = '{' + ','.join('[' + quote(s) + ']=' + s for s in data['exports']) + '}'
    body = ('local function run_module()\n'
            'setfenv(1, setmetatable({ ENT = ENT, SWEP = SWEP }, { __index = _G }))\n'
            + bindings + bundle + ('\n' + data['main'] + '()\n' if data.get('main') else '')
            + '\nreturn ' + exports + '\nend\n')
    if named:
        body += ('local ok, value = pcall(run_module)\n'
                 'if not ok then project[id] = {failed = true, error = value}; error(value) end\n'
                 'project[id] = {value = value}\nreturn value\n')
    else:
        body += 'run_module()\n'
    return 'do\n' + prefix + body + 'end\n'


def assemble_mirrored(root, output, config):
    entries, raw = mirror_plan(root, config)
    addon = config['project_type'] == 'addon'
    paths = [(rel, realm) for _, rel, realm in entries]
    paths += [(rel, infer_realm(rel)) for _, rel in raw if rel.lower().endswith('.lua')]
    transfers = []
    for relative, realm in sorted(paths):
        if realm == 'server':
            continue
        if addon and relative.startswith('lua/'):
            virtual = relative[4:]
        elif not addon and relative.startswith('gamemode/'):
            virtual = config['name'] + '/' + relative
        elif not addon and relative.startswith('entities/'):
            virtual = relative[len('entities/'):]
        else:
            continue
        transfers.append(f'AddCSLuaFile({quote(virtual)})\n')
    transfer = '-- Generated client transfer list (does not execute files)\n' + ''.join(transfers)
    for _, relative, realm in entries:
        def bundle(current):
            return (root / f'build/mirror/{current}/{relative}').read_text(encoding='utf-8')
        content = (f'if SERVER then\n{bundle("server")}else\n{bundle("client")}end\n'
                   if realm == 'shared' else f'if {"SERVER" if realm == "server" else "CLIENT"} then\n{bundle(realm)}end\n')
        if not addon and relative == 'gamemode/init.lua':
            content = transfer + content
        put(output, relative, '-- Generated by HxGMod; edit the mirrored .hx source\n' + content)
    for path, relative in raw:
        if not addon and relative == 'gamemode/init.lua':
            put(output, relative, transfer + path.read_text(encoding='utf-8-sig'))
        else:
            put(output, relative, source=path)
    if addon:
        put(output, f'lua/autorun/server/{config["name"]}_hxgmod_transfer.lua', transfer)
    else:
        gm = {'base': 'sandbox', 'title': config['name'], 'category': 'other', 'menusystem': '1', **config.get('gamemode', {})}
        put(output, config['name'] + '.txt', quote(config['name']) + '\n{\n' + ''.join(f'    {quote(k)} {quote(v)}\n' for k, v in gm.items()) + '}\n')


def haxe_entry(package, name, body):
    return ('package' + (' ' + package if package else '') + ';\n\nclass ' + name
            + ' {\n    public static function main():Void {\n' + body + '\n    }\n}\n')


def haxe_class_name(value):
    name = ''.join(part.title() for part in re.split('[_-]', value))
    return name if name[0].isalpha() else 'Hx' + name


def scaffold_mirrored(target, config):
    def entry(relative, body, package='', name='Main'):
        path = target / 'src' / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(haxe_entry(package, name, body), encoding='utf-8')
    if config['project_type'] == 'addon':
        name = haxe_class_name(config['name']) + 'Startup'
        entry(f'lua/autorun/server/{name}.hx',
              '        lua.Lua.print(' + quote(config['name'] + ' loaded') + ');', 'autorun.server', name)
    else:
        entry('gamemode-root/gamemode/shared.hx',
              '        untyped __lua__("DeriveGamemode({0})", ' + quote(config.get('gamemode', {}).get('base', 'sandbox')) + ');')
        for filename in ('init', 'cl_init'):
            entry(f'gamemode-root/gamemode/{filename}.hx', '        gmod.LuaScripts.include("shared.lua");')


def build_project(root, realm='all'):
    config = load_config(root)
    check_library(root)
    safe_dir(root, 'build').mkdir(exist_ok=True)
    # Invalidate packaging before compiling: failed builds must never ship old bundles.
    stamp = root / 'build/complete.json'
    stamp.unlink(missing_ok=True)
    if mirrored(config):
        build_mirrored(root, config, realm)
    else:
        print('[HxGMod] Legacy bundles/targets are deprecated; see docs/filesystem.md.')
        realms = ('server', 'client') if realm == 'all' else (realm,)
        for current in realms:
            safe_dir(root, f'build/{current}').mkdir(parents=True, exist_ok=True)
            run(['haxe', f'build-{current}.hxml'], root)
            for kind in ('entities', 'weapons'):
                for name, main in config.get(kind, {}).items():
                    out = safe_dir(root, f'build/{kind}/{name}/{current}.lua')
                    out.parent.mkdir(parents=True, exist_ok=True)
                    run(['haxe', '-lib', 'hxgmod', '-cp', 'src', '-main', main, '--lua', str(out), *compiler_flags(current)], root)
    if realm == 'all':
        outputs = expected_outputs(config, root)
        missing = [p for p in outputs if not (root / p).is_file()]
        if missing:
            raise HxGModError(f'Build did not produce required output: {missing[0]}. Check your HXML output paths.')
        stamp.write_text(json.dumps({'inputs': fingerprint(root), 'outputs': {p: digest(root / p) for p in outputs}}, indent=2), encoding='utf-8')
    print(f'[HxGMod] Built {realm}.')


def digest(path):
    result = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            result.update(chunk)
    return result.hexdigest()


def fingerprint(root):
    paths = [root / 'hxgmod.json', *root.glob('*.hxml')]
    for directory in ('src', 'lua', 'package-root', *ASSET_DIRS):
        paths.extend(source_files(root / directory))
    result = {str(p.relative_to(root)): digest(p) for p in sorted(paths)}
    # Bindings and handwritten helpers affect compilation too.
    result['SDK'] = hashlib.sha256(''.join(digest(p) for p in sorted((SDK_ROOT / 'src').rglob('*.hx'))).encode()).hexdigest()
    result['CLI'] = digest(Path(__file__))
    return result


def expected_outputs(config, root=None):
    if mirrored(config):
        entries, _ = mirror_plan(root, config)
        return [f'build/mirror/{realm}/{relative}' for _, relative, inferred in entries
                for realm in (('server', 'client') if inferred == 'shared' else (inferred,))]
    result = [f'build/{r}/hxgmod_{r}.lua' for r in ('server', 'client')]
    result += [f'build/{k}/{n}/{r}.lua' for k in ('entities', 'weapons') for n in config.get(k, {}) for r in ('server', 'client')]
    return result


def verify_build(root, config):
    try:
        stamp = json.loads((root / 'build/complete.json').read_text(encoding='utf-8'))
        if stamp['inputs'] != fingerprint(root) or stamp['outputs'] != {p: digest(root / p) for p in expected_outputs(config, root)}:
            raise ValueError('stale')
    except (OSError, ValueError, KeyError):
        raise HxGModError('Build is missing, incomplete, or stale. Run hxgmod build --package (all realms).')


def put(output, relative, content=None, source=None):
    validate_package_path(relative)
    target = output / relative
    # Windows and GMod paths collide without regard to case.
    existing = {p.relative_to(output).as_posix().lower() for p in output.rglob('*') if p.is_file()}
    low = relative.lower()
    if any(low == p or low.startswith(p + '/') or p.startswith(low + '/') for p in existing):
        raise HxGModError(f'Package file collision: {relative}. Remove the duplicate raw/generated destination.')
    target.parent.mkdir(parents=True, exist_ok=True)
    if source is not None:
        shutil.copy2(source, target)
    else:
        target.write_text(content, encoding='utf-8')


def quote(value):
    # JSON's unicode escapes are not Lua 5.1 string escapes.
    return json.dumps(str(value), ensure_ascii=False)


def isolate_bundle(bundle):
    # Haxe emits some runtime helpers as globals. Every bundle gets a private
    # environment so loading another entity/addon cannot replace those helpers.
    return ('do\nlocal function hxgmod_bundle()\n'
            'setfenv(1, setmetatable({ ENT = ENT, SWEP = SWEP }, { __index = _G }))\n'
            + bundle + '\nend\nhxgmod_bundle()\nend\n')


def assemble(root, output, config):
    if mirrored(config):
        return assemble_mirrored(root, output, config)
    addon = config['project_type'] == 'addon'
    name = config['name']
    for realm in ('server', 'client'):
        bundle = (root / f'build/{realm}/hxgmod_{realm}.lua').read_text(encoding='utf-8')
        if addon:
            relative = f'lua/autorun/{realm}/{name}_{realm}.lua'
            prefix = f'AddCSLuaFile("autorun/client/{name}_client.lua")\n' if realm == 'server' else ''
        else:
            relative = 'gamemode/' + ('init.lua' if realm == 'server' else 'cl_init.lua')
            prefix = 'AddCSLuaFile("cl_init.lua")\n' if realm == 'server' else ''
            prefix += f'DeriveGamemode({quote(config.get("gamemode", {}).get("base", "sandbox"))})\n'
        put(output, relative, '-- Generated by HxGMod\n' + prefix + isolate_bundle(bundle))
    if not addon:
        gm = {'base': 'sandbox', 'title': name, 'category': 'other', 'menusystem': '1', **config.get('gamemode', {})}
        put(output, f'{name}.txt', quote(name) + '\n{\n' + ''.join(f'    {quote(k)} {quote(v)}\n' for k, v in gm.items()) + '}\n')
    for kind in ('entities', 'weapons'):
        for classname in config.get(kind, {}):
            base = ('lua/' if addon else 'entities/') + f'{kind}/{classname}'
            for realm, filename in (('server', 'init.lua'), ('client', 'cl_init.lua')):
                prefix = 'AddCSLuaFile("cl_init.lua")\n' if realm == 'server' else ''
                bundle = (root / f'build/{kind}/{classname}/{realm}.lua').read_text(encoding='utf-8')
                put(output, f'{base}/{filename}', '-- Generated by HxGMod\n' + prefix + isolate_bundle(bundle))
    for path, relative in raw_files(root, config):
        for kind in ('entities', 'weapons'):
            base = ('lua/' if addon else 'entities/') + kind + '/'
            for classname in config.get(kind, {}):
                low = relative.lower()
                if low == base + classname + '.lua' or low.startswith(base + classname + '/'):
                    raise HxGModError(f'Raw file conflicts with compiled target: {relative}')
        put(output, relative, source=path)


def replace_tree(stage, destination):
    backup = destination.with_name(destination.name + '.hxgmod-old')
    if backup.exists():
        raise HxGModError(f'Previous backup exists; inspect it before retrying: {backup}')
    if destination.exists():
        destination.rename(backup)
    try:
        stage.rename(destination)
    except BaseException:
        if backup.exists():
            backup.rename(destination)
        raise
    if backup.exists():
        shutil.rmtree(backup)


def package_project(root):
    config = load_config(root)
    verify_build(root, config)
    dist = safe_dir(root, 'dist')
    dist.mkdir(exist_ok=True)
    destination = safe_dir(root, f'dist/{config["name"]}')
    with staging_directory(dist) as temporary:
        stage = Path(temporary) / 'package'
        stage.mkdir()
        assemble(root, stage, config)
        replace_tree(stage, destination)
    print(f'[HxGMod] Packaged: {destination}')
    return destination


def install_destination(root, config, supplied=None):
    value = supplied or config.get('install_path')
    if not value:
        raise HxGModError('Supply the garrysmod folder, addons/gamemodes folder, or set install_path.')
    target = Path(value).expanduser()
    if not target.is_absolute():
        target = root / target
    target = target.resolve()
    kind = 'addons' if config['project_type'] == 'addon' else 'gamemodes'
    if (target / 'garrysmod').is_dir():
        target /= 'garrysmod'
    if target.name.lower() == 'garrysmod':
        target /= kind
    if target.name.lower() != kind:
        raise HxGModError(f'Install directory must be a garrysmod root or a {kind} directory.')
    destination = safe_dir(target, config['name'])
    if destination == root or root.is_relative_to(destination) or destination.is_relative_to(root):
        raise HxGModError('Install destination must be outside the source project.')
    return destination


def install_project(root, supplied=None):
    config = load_config(root)
    destination = install_destination(root, config, supplied)
    target = destination.parent
    if destination.exists():
        try:
            marker = json.loads((destination / MARKER).read_text(encoding='utf-8'))
            if marker['project'] != str(root.resolve()):
                raise ValueError('different project')
            actual = {p.relative_to(destination).as_posix(): digest(p) for p in destination.rglob('*') if p.is_file() and p != destination / MARKER}
            if marker['files'] != actual:
                raise ValueError('installed files were changed')
        except (OSError, ValueError, KeyError):
            raise HxGModError(f'Existing installation is untracked or modified: {destination}. Move it to a backup folder first.')
    source = package_project(root)
    target.mkdir(parents=True, exist_ok=True)
    with staging_directory(target) as temporary:
        stage = Path(temporary) / 'package'
        shutil.copytree(source, stage)
        files = {p.relative_to(stage).as_posix(): digest(p) for p in stage.rglob('*') if p.is_file()}
        (stage / MARKER).write_text(json.dumps({'project': str(root.resolve()), 'files': files}, indent=2), encoding='utf-8')
        replace_tree(stage, destination)
    print(f'[HxGMod] Installed: {destination}')


def scaffold_sources(target):
    for realm in ('server', 'client', 'shared'):
        folder = target / 'src' / realm
        folder.mkdir(parents=True)
        entry = 'init' if realm == 'shared' else 'main'
        body = '' if realm == 'shared' else '        shared.SharedMain.init();\n'
        (folder / f'{realm.title()}Main.hx').write_text(f'package {realm};\n\nclass {realm.title()}Main\n{{\n    public static function {entry}():Void\n    {{\n{body}    }}\n}}\n', encoding='utf-8')


def command_new(args):
    name = valid_name(args.name)
    target = Path(args.directory or name).expanduser().resolve()
    if target.exists() and (not target.is_dir() or any(target.iterdir())):
        raise HxGModError(f'Target is not an empty directory: {target}')
    target.mkdir(parents=True, exist_ok=True)
    (target / '.gitignore').write_text('build/\ndist/\n', encoding='utf-8')
    config = {'project_type': args.project_type, 'name': name, 'source_layout': 'filesystem'}
    if args.project_type == 'gamemode':
        config['gamemode'] = {'title': args.title or name, 'base': args.base, 'category': args.category, 'maps': args.maps or ''}
    scaffold_mirrored(target, config)
    save_config(target, config)
    (target / 'README.md').write_text('# ' + name + '\n\nRun `hxgmod build --package`, then `hxgmod install "PATH/garrysmod"`.\n'
        '\nEdit the starter under `src/`. Run `hxgmod add --help` to add scripts, entities or weapons.\n'
        'Mirrored Haxe files become separate Lua files; imports between them share state within each realm.\n'
        '`src/shared/` is optional space for bundled Haxe helpers, not a GMod directory.\n'
        '\nPlace ready-to-use assets in `models/`, `materials/`, `sound/`, `resource/`, `particles/` or `maps/`.\n'
        'Build/package copies all companion files automatically (gamemodes use `content/` in the output).\n'
        'Use normal GMod paths such as `models/my_prop/prop.mdl`. See the SDK docs/assets.md for client downloads.\n'
        '\nSet optional `install_path` in hxgmod.json to reuse a deployment destination. JSON does not allow comments.\n'
        'Run `hxgmod doctor` for diagnostics. `hxgmod --verbose build` shows compiler commands.\n', encoding='utf-8')
    print(f'[HxGMod] Created {target}\n[HxGMod] Next: cd "{target}"\n[HxGMod] Then: hxgmod build --package')


def command_add(args):
    root = require_project_root()
    config = load_config(root)
    if not mirrored(config):
        raise HxGModError('add requires source_layout: filesystem. See docs/filesystem.md for migration; existing legacy builds still work.')
    name = valid_name(args.name)
    addon = config['project_type'] == 'addon'
    base = 'src/lua' if addon else 'src/gamemode-root'
    files = {}
    if args.kind in ('entity', 'swep'):
        if args.realm is not None:
            raise HxGModError('Entities and SWEPs generate shared, server and client loaders; omit --realm.')
        if '-' in name:
            raise HxGModError('Entity/SWEP class names must use underscores instead of hyphens.')
        if args.kind == 'swep' and not name.startswith('weapon_'):
            name = 'weapon_' + name
        folder = ('entities' if args.kind == 'entity' else 'weapons') + '/' + name
        if not addon:
            folder = 'entities/' + folder
        # ENT/SWEP setup must run on every loader invocation, so these conventional
        # lowercase GMod loaders deliberately retain the supported Main form.
        text = (SDK_ROOT / f'tools/templates/{args.kind}.hx').read_text(encoding='utf-8')
        files[f'{base}/{folder}/shared.hx'] = text.replace('HXGMOD_TITLE', name)
        for loader in ('init', 'cl_init'):
            files[f'{base}/{folder}/{loader}.hx'] = haxe_entry('', 'Main', '        gmod.LuaScripts.include("shared.lua");')
    else:
        realm = args.realm or 'server'
        if args.kind == 'autorun' and not addon:
            raise HxGModError('Gamemodes load init.hx/cl_init.hx. Use add script NAME, then import it from a gamemode loader.')
        classname = haxe_class_name(config['name'] + '_' + name)
        folder = ('autorun' if addon else 'gamemode') + ('' if realm == 'shared' else '/' + realm)
        package = folder.replace('/', '.')
        identifier = config['name'] + '_' + name
        body = '        lua.Lua.print(' + quote(identifier + ' loaded') + ');'
        if args.kind == 'hook':
            body = '        gmod.Hook.add("Initialize", ' + quote(identifier) + ', function():Void {\n            lua.Lua.print("Initialized");\n        });'
        elif args.kind == 'command':
            body = '        gmod.ConcommandLib.add(' + quote(identifier) + ', function(ply, command, args, text):Void {\n            lua.Lua.print("Hello from ' + identifier + '");\n        });'
        files[f'{base}/{folder}/{classname}.hx'] = haxe_entry(package, classname, body)
    # Validate all destinations before writing any file. Also catch raw output
    # conflicts and case-only paths using the same planner as build/package.
    for relative in files:
        path = safe_dir(root, relative)
        if path.exists():
            raise HxGModError(f'Already exists: {path}. Choose another name; add never overwrites files.')
    written = []
    try:
        for relative, text in files.items():
            path = root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            with path.open('x', encoding='utf-8') as handle:
                handle.write(text)
            written.append(path)
        mirror_plan(root, config)
    except BaseException:
        for path in written:
            path.unlink()
        raise
    for path in written:
        print(f'[HxGMod] Added {path.relative_to(root)}')
    if not addon and args.kind not in ('entity', 'swep'):
        virtual = ('' if realm == 'shared' else realm + '/') + classname + '.lua'
        print(f'[HxGMod] Add to a matching gamemode loader: gmod.LuaScripts.include({quote(virtual)});')
    print('[HxGMod] Next: hxgmod build --package')


def command_doctor(args):
    problems = []
    print(f'[HxGMod] SDK {VERSION}: {SDK_ROOT}\n[HxGMod] Python: {sys.version.split()[0]}')
    print('[HxGMod] Lua target needs Haxe and Python; hxjava/JDK are not required.')
    for command, option in (('haxe', '--version'), ('haxelib', 'version')):
        try:
            result = run([command, option], SDK_ROOT, capture=True)
            print(f'{command}: {(result.stdout or result.stderr).strip()}')
        except HxGModError as exc:
            problems.append(str(exc))
    try:
        check_library(find_project_root() or Path.cwd())
    except HxGModError as exc:
        problems.append(str(exc))
    launcher = shutil.which('hxgmod')
    print(f'[HxGMod] PATH launcher: {launcher or "missing; run setup.ps1 or use the full hxgmod.bat path"}')
    if launcher and Path(launcher).resolve() != (SDK_ROOT / 'hxgmod.bat').resolve():
        problems.append('PATH points to another SDK; run this SDK setup.ps1 and reopen your terminal.')
    count = len(list((SDK_ROOT / 'src/gmod/generated').rglob('*.hx')))
    print(f'[HxGMod] Generated bindings: {count}')
    if not count:
        problems.append('Bindings missing; run hxgmod update --offline with cached API data, or hxgmod update.')
    if any((SDK_ROOT / 'src' / p).exists() for p in ('server', 'client', 'shared', 'Main.hx')):
        problems.append('Demo entrypoints remain in the library source path.')
    root = find_project_root()
    if root:
        config = load_config(root)
        print(f'[HxGMod] Project: {root} ({config["project_type"]})')
        if config.get('install_path'):
            try:
                destination = install_destination(root, config)
                if not destination.parent.exists():
                    problems.append(f'Install path does not exist: {destination.parent}. Fix install_path or pass the actual garrysmod folder to install.')
                else:
                    print(f'[HxGMod] Install destination: {destination}')
            except HxGModError as exc:
                problems.append(str(exc))
        else:
            print('[HxGMod] Install path not set (optional); use hxgmod install "PATH/garrysmod".')
        for wrong, right in (('sounds', 'sound'), ('model', 'models'), ('material', 'materials'), ('assets', 'models/, materials/, sound/, resource/, particles/ or maps/')):
            if (root / wrong).exists():
                problems.append(f'{wrong}/ is not packaged automatically. Move its contents into {right}, or use package-root/ for explicit destinations.')
        if (root / 'data').exists():
            problems.append('data/ is runtime storage, not a distributable asset folder. Put read-only defaults in a suitable resource/ path and create runtime data with GMod APIs.')
        if mirrored(config):
            try:
                entries, raw = mirror_plan(root, config)
                print(f'[HxGMod] Mirrored entries: {len(entries)}; raw files: {len(raw)}')
            except HxGModError as exc:
                problems.append(str(exc))
        else:
            print('[HxGMod] Legacy layout; migrate with docs/filesystem.md.')
            for realm in ('server', 'client'):
                if not (root / f'build-{realm}.hxml').is_file():
                    problems.append(f'Missing build-{realm}.hxml')
                if not (root / f'src/{realm}/{realm.title()}Main.hx').is_file():
                    print(f'[HxGMod] Note: default {realm} entrypoint missing; check HXML if using a custom main.')
            for kind in ('entities', 'weapons'):
                for name, main in config.get(kind, {}).items():
                    if not (root / 'src' / (main.replace('.', '/') + '.hx')).is_file():
                        problems.append(f'Missing {kind} entrypoint {main} ({name})')
        try:
            verify_build(root, config)
            print('[HxGMod] Package inputs: current')
        except HxGModError as exc:
            print('[HxGMod] ' + str(exc))
    else:
        print('[HxGMod] No project here. Create one with hxgmod new addon NAME.')
    if problems:
        raise HxGModError('\n'.join(problems))
    print('[HxGMod] Doctor passed.')


def command_update(args):
    # Generate in isolation; a failed download/generator leaves the working library intact.
    with staging_directory(SDK_ROOT / '.work', prefix='update-') as temporary:
        stage = Path(temporary)
        shutil.copytree(SDK_ROOT / 'generator', stage / 'generator')
        shutil.copy2(SDK_ROOT / 'generator.hxml', stage / 'generator.hxml')
        shutil.copytree(SDK_ROOT / 'src/gmod', stage / 'src/gmod')
        if args.offline:
            shutil.copytree(SDK_ROOT / 'api', stage / 'api')
        else:
            run([sys.executable, str(SDK_ROOT / 'tools/update_api.py')], stage)
        run(['haxe', 'generator.hxml'], stage)
        if not list((stage / 'src/gmod/generated').rglob('*.hx')):
            raise HxGModError('Generator produced no bindings.')
        (stage / 'src/BindingCheck.hx').write_text('class BindingCheck { static function main() {} }', encoding='utf-8')
        for realm in (None, 'server', 'client'):
            flags = compiler_flags(realm) if realm else ['-D', 'lua-ver=5.1', '-D', 'lua-vanilla']
            run(['haxe', '-cp', 'src', '-main', 'BindingCheck', '--lua', 'check.lua',
                 '--macro', "include('gmod')", *flags], stage)
        # Compare before changing anything; handwritten public files are invariant.
        for path in (SDK_ROOT / 'src/gmod').glob('*.hx'):
            if not path.read_text(encoding='utf-8').startswith('// @hxgmod-generated-public-alias'):
                if (stage / 'src/gmod' / path.name).read_bytes() != path.read_bytes():
                    raise HxGModError(f'Generator changed handwritten file: {path.name}')
        # Keep both backups until both swaps succeed (including API provenance).
        swaps = [(stage / 'src/gmod', SDK_ROOT / 'src/gmod'), (stage / 'api', SDK_ROOT / 'api')]
        moved = []
        try:
            for source, destination in swaps:
                backup = destination.with_name(destination.name + '.hxgmod-old')
                if backup.exists():
                    raise HxGModError(f'Inspect leftover update backup before retrying: {backup}')
                destination.rename(backup)
                moved.append((destination, backup))
                source.rename(destination)
        except BaseException:
            for destination, backup in reversed(moved):
                if destination.exists():
                    shutil.rmtree(destination)
                backup.rename(destination)
            raise
        for destination, backup in moved:
            shutil.rmtree(backup)
    print('[HxGMod] Bindings updated. Rebuild your projects.')


def main():
    parser = argparse.ArgumentParser(prog='hxgmod', description='Haxe to Garry\'s Mod toolchain')
    parser.add_argument('--verbose', action='store_true', help='Show compiler commands and tool output')
    parser.add_argument('--project', type=Path, help='Project directory (or any directory inside it)')
    parser.add_argument('--version', action='version', version=VERSION)
    sub = parser.add_subparsers(dest='command', required=True)
    new = sub.add_parser('new', help='Create a minimal external project')
    new.add_argument('project_type', choices=('addon', 'gamemode'))
    new.add_argument('name')
    new.add_argument('directory', nargs='?')
    new.add_argument('--title')
    new.add_argument('--base', default='sandbox')
    new.add_argument('--category', default='other', choices=('other', 'rp', 'pvp', 'pve'))
    new.add_argument('--maps')
    new.set_defaults(func=command_new)
    add = sub.add_parser('add', help='Add a minimal script, hook, command, entity or SWEP without overwriting files')
    add.add_argument('kind', choices=('autorun', 'script', 'hook', 'command', 'entity', 'swep'))
    add.add_argument('name', help='Lowercase name; use a unique entity/SWEP class name')
    add.add_argument('--realm', choices=('server', 'client', 'shared'), help='Scripts default to server; entity/SWEP loaders cover both realms')
    add.set_defaults(func=command_add)
    build = sub.add_parser('build', help='Compile mirrored entry files (or legacy configured bundles)')
    build.add_argument('realm', nargs='?', default='all', choices=('all', 'server', 'client'))
    build.add_argument('--package', action='store_true')
    build.add_argument('--install', nargs='?', const='', metavar='GARRYSMOD_OR_TARGET_DIR')
    for name, help_text in {'package': 'Assemble a complete, unchanged build into dist/NAME',
            'install': 'Package and safely copy into Garry\'s Mod',
            'clean': 'Remove generated build/ and dist/; retain source and assets',
            'doctor': 'Check tools, project, asset paths and deployment configuration',
            'register': 'Register this SDK with haxelib', 'unregister': 'Remove the haxelib development override'}.items():
        command = sub.add_parser(name, help=help_text)
        if name == 'install':
            command.add_argument('path', nargs='?')
    update = sub.add_parser('update', help='Safely regenerate bindings; cached API supported')
    update.add_argument('--offline', action='store_true')
    update.set_defaults(func=command_update)
    args = parser.parse_args()
    global VERBOSE
    VERBOSE = args.verbose
    try:
        if args.project is not None:
            import os
            os.chdir(args.project)
        if hasattr(args, 'func'):
            args.func(args)
        elif args.command == 'doctor':
            command_doctor(args)
        elif args.command in ('register', 'unregister'):
            command = ['haxelib', 'dev', 'hxgmod']
            if args.command == 'register':
                command.append(str(SDK_ROOT))
            run(command, SDK_ROOT)
        else:
            root = require_project_root()
            load_config(root)
            if args.command == 'build':
                if args.realm != 'all' and (args.package or args.install is not None):
                    raise HxGModError('Packaging/installing requires all realms. Use hxgmod build --package.')
                build_project(root, args.realm)
                if args.install is not None:
                    install_project(root, args.install)
                elif args.package:
                    package_project(root)
            elif args.command == 'package':
                package_project(root)
            elif args.command == 'install':
                install_project(root, args.path)
            elif args.command == 'clean':
                for directory in ('build', 'dist'):
                    delete_output(root, directory)
                print('[HxGMod] Cleaned build and dist.')
        return 0
    except (HxGModError, OSError) as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print('Cancelled.', file=sys.stderr)
        return 130


if __name__ == '__main__':
    raise SystemExit(main())
