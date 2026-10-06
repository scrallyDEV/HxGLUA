"""Release UX checks: real builds plus both Lua runtimes; no game/network needed."""
import importlib
import contextlib
import io
import json
import subprocess
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
import test_toolchain
from test_toolchain import cli


class ReleaseUX(unittest.TestCase):
    setUpClass = classmethod(test_toolchain.Toolchain.setUpClass.__func__)
    tearDownClass = classmethod(test_toolchain.Toolchain.tearDownClass.__func__)
    invoke = test_toolchain.Toolchain.invoke

    def new(self, name, kind='addon'):
        root = self.root / (name + ' project with spaces')
        cli.command_new(SimpleNamespace(name=name, directory=str(root), project_type=kind,
            title='Test mode', base='sandbox', category='other', maps=''))
        return root

    def test_minimal_scaffolds_build_and_nested_project_selection(self):
        for kind in ('addon', 'gamemode'):
            root = self.new('starter_' + kind, kind)
            self.assertFalse((root / 'src/shared').exists())
            self.assertNotIn('install_path', json.loads((root / 'hxgmod.json').read_text()))
            self.assertEqual(len(list((root / 'src').rglob('*.hx'))), 1 if kind == 'addon' else 3)
            self.invoke(root / 'src', 'build', '--package')
            self.assertEqual(cli.find_project_root(next((root / 'src').rglob('*.hx'))), root)
            self.invoke(self.root, '--project', str(root / 'src'), 'package')
            for backend in ('lua51', 'luajit21'):
                runtime = importlib.import_module('lupa.' + backend).LuaRuntime()
                runtime.execute('SERVER=true; CLIENT=false; function AddCSLuaFile(p) end; function DeriveGamemode(n) base=n end')
                package = root / 'dist' / ('starter_' + kind)
                if kind == 'addon':
                    runtime.execute(next((package / 'lua/autorun/server').glob('*Startup.lua')).read_text())
                else:
                    runtime.globals().include = lambda name: runtime.execute((package / 'gamemode' / name).read_text())
                    runtime.execute((package / 'gamemode/init.lua').read_text())
                    self.assertEqual(runtime.globals().base, 'sandbox')

    def test_assets_companions_freshness_stale_cleanup_and_gamemode_content(self):
        for kind in ('addon', 'gamemode'):
            name = 'assets_' + kind
            root = self.new(name, kind)
            files = ['models/my prop/prop' + ext for ext in ('.mdl', '.vvd', '.dx90.vtx', '.phy')]
            files += ['materials/my prop/prop.vmt', 'materials/my prop/prop.vtf', 'sound/my prop/test.wav',
                'resource/test.txt', 'particles/test.pcf', 'maps/test.bsp']
            for i, relative in enumerate(files):
                path = root / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(bytes([0, i, 255]))
            self.invoke(root, 'build', '--package')
            output = root / 'dist' / name
            if kind == 'gamemode':
                output /= 'content'
            for relative in files:
                self.assertEqual((output / relative).read_bytes(), (root / relative).read_bytes())
            (root / files[0]).write_bytes(b'changed')
            self.assertIn('stale', self.invoke(root, 'package', okay=False).stderr)
            (root / files[-1]).unlink()
            self.invoke(root, 'build', '--package')
            self.assertFalse((output / files[-1]).exists())
            self.assertEqual((output / files[0]).read_bytes(), b'changed')
            before = {str(p.relative_to(output)): p.read_bytes() for p in output.rglob('*') if p.is_file()}
            self.invoke(root, 'package')
            self.assertEqual(before, {str(p.relative_to(output)): p.read_bytes() for p in output.rglob('*') if p.is_file()})
            self.invoke(root, 'clean')
            self.assertFalse((root / 'dist').exists())
            self.assertEqual((root / files[0]).read_bytes(), b'changed')

    def test_asset_collisions_and_portable_path_validation(self):
        for kind in ('addon', 'gamemode'):
            root = self.new('collision_' + kind, kind)
            first = root / 'models/prop.mdl'
            other = root / ('package-root/models/PROP.mdl' if kind == 'addon' else 'package-root/content/models/PROP.mdl')
            for path in (first, other):
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('fixture')
            self.assertIn('collision', self.invoke(root, 'build', okay=False).stderr)
            self.assertIn('collision', self.invoke(root, 'doctor', okay=False).stderr)
        for relative in ('../escape', '/absolute', 'models/a:b', 'models/con.mdl', 'models/a.', 'models/a\\b', cli.MARKER):
            with self.assertRaises(cli.HxGModError):
                cli.validate_package_path(relative)
        with cli.staging_directory(self.root) as output:
            cli.put(output, 'models/a', 'x')
            with self.assertRaisesRegex(cli.HxGModError, 'collision'):
                cli.put(output, 'models/A/b', 'x')

    def test_generators_build_no_overwrite_and_runtime(self):
        for kind in ('addon', 'gamemode'):
            root = self.new('generated_' + kind, kind)
            for feature in ('entity', 'swep', 'hook', 'command', 'script'):
                self.invoke(root / 'src', 'add', feature, 'test_' + feature)
            if kind == 'addon':
                for realm in ('server', 'client', 'shared'):
                    self.invoke(root, 'add', 'autorun', 'test_' + realm, '--realm', realm)
            else:
                self.assertIn('add script', self.invoke(root, 'add', 'autorun', 'bad', okay=False).stderr)
            snapshot = {str(p): p.read_bytes() for p in (root / 'src').rglob('*.hx')}
            self.assertIn('Already exists', self.invoke(root, 'add', 'entity', 'test_entity', okay=False).stderr)
            self.assertEqual(snapshot, {str(p): p.read_bytes() for p in (root / 'src').rglob('*.hx')})
            self.invoke(root, 'build', '--package')
            output = root / 'dist' / ('generated_' + kind)
            for backend in ('lua51', 'luajit21'):
                for server in (True, False):
                    runtime = importlib.import_module('lupa.' + backend).LuaRuntime()
                    runtime.execute('SERVER=' + str(server).lower() + '; CLIENT=not SERVER; ENT={}; SWEP={}; function AddCSLuaFile(p) end; SOLID_VPHYSICS=6; MOVETYPE_VPHYSICS=6')
                    if server:
                        runtime.execute('hooks={}; commands={}; hook={Add=function(event,id,fn) hooks[id]=fn end}; concommand={Add=function(id,fn) commands[id]=fn end}')
                        scripts = output / ('lua/autorun/server' if kind == 'addon' else 'gamemode/server')
                        for suffix in ('Hook', 'Command'):
                            runtime.execute(next(scripts.glob('*Test' + suffix + '.lua')).read_text())
                        identifier = 'generated_' + kind
                        self.assertIsNotNone(runtime.globals().hooks[identifier + '_test_hook'])
                        self.assertIsNotNone(runtime.globals().commands[identifier + '_test_command'])
                        runtime.globals().hooks[identifier + '_test_hook']()
                        runtime.globals().commands[identifier + '_test_command'](None, '', None, '')
                    for feature, folder, context in (('entity', 'entities/test_entity', 'ENT'), ('swep', 'weapons/weapon_test_swep', 'SWEP')):
                        directory = output / ('lua' if kind == 'addon' else 'entities') / folder
                        runtime.globals().include = lambda name: runtime.execute((directory / name).read_text())
                        runtime.execute((directory / ('init.lua' if server else 'cl_init.lua')).read_text())
                        self.assertTrue(runtime.globals()[context].Spawnable)
            self.invoke(root, 'add', 'entity', 'bad-name', okay=False)
            self.invoke(root, 'add', 'entity', 'bad_realm', '--realm', 'client', okay=False)

    def test_friendly_errors_tools_config_paths_and_help(self):
        root = self.new('diagnostics')
        with patch.object(cli.subprocess, 'run', side_effect=FileNotFoundError):
            with self.assertRaisesRegex(cli.HxGModError, 'missing.*Install'):
                cli.run(['haxe', '--version'], root)
        result = self.invoke(self.root, 'build', okay=False)
        self.assertIn('hxgmod new addon', result.stderr)
        self.assertNotIn('Traceback', result.stderr)
        self.invoke(root, 'install', 'not a game folder', okay=False)
        config = cli.load_config(root)
        config['install_path'] = '../missing/garrysmod'
        cli.save_config(root, config)
        self.assertIn('Install path does not exist', self.invoke(root, 'doctor', okay=False).stderr)
        (root / 'hxgmod.json').write_text('{bad json')
        result = self.invoke(root, 'doctor', okay=False)
        self.assertIn('hxgmod.json', result.stderr)
        self.assertNotIn('Traceback', result.stderr)
        self.assertIn('add', self.invoke(self.root, '--help').stdout)
        version = json.loads((cli.SDK_ROOT / 'haxelib.json').read_text())['version']
        self.assertEqual(self.invoke(self.root, '--version').stdout.strip(), version)

    def test_wrong_module_names_and_generator_raw_collision(self):
        root = self.new('module_errors')
        bad = root / 'src/lua/mistake.hx'
        bad.write_text('package; class Mistake {}')
        result = self.invoke(root, 'build', okay=False)
        self.assertIn('capitalized', result.stderr)
        self.assertIn('mistake.hx', result.stderr)
        bad.unlink()
        bad = root / 'src/lua/Mistake.hx'
        bad.write_text('package wrong; class Mistake {}')
        self.assertIn('package', self.invoke(root, 'build', okay=False).stderr)
        bad.unlink()
        raw = root / 'lua/entities/test_entity/shared.lua'
        raw.parent.mkdir(parents=True)
        raw.write_text('original')
        self.assertIn('collision', self.invoke(root, 'add', 'entity', 'test_entity', okay=False).stderr)
        self.assertFalse(list((root / 'src/lua/entities').rglob('*.hx')))
        self.assertEqual(raw.read_text(), 'original')

    def test_successful_compiler_warnings_remain_visible(self):
        warning = io.StringIO()
        result = SimpleNamespace(returncode=0, stdout='', stderr='Warning: deprecated API\n')
        with patch.object(cli.subprocess, 'run', return_value=result), contextlib.redirect_stderr(warning):
            cli.run(['haxe'], self.root)
        self.assertIn('deprecated API', warning.getvalue())

    def test_legacy_conventional_assets_and_folder_typos(self):
        root = self.new('legacy_assets')
        config = cli.load_config(root)
        config.pop('source_layout')
        cli.save_config(root, config)
        self.assertFalse(cli.mirrored(cli.load_config(root)))
        cli.scaffold_sources(root)
        for realm in ('server', 'client'):
            (root / f'build-{realm}.hxml').write_text(cli.build_hxml(realm))
        model = root / 'models/legacy/test.mdl'
        model.parent.mkdir(parents=True)
        model.write_bytes(b'fixture')
        self.invoke(root, 'build', '--package')
        self.assertEqual((root / 'dist/legacy_assets/models/legacy/test.mdl').read_bytes(), b'fixture')
        (root / 'sounds').mkdir()
        self.assertIn('sounds/', self.invoke(root, 'doctor', okay=False).stderr)


if __name__ == '__main__':
    unittest.main()
