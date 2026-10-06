"""Focused filesystem compiler integration tests; real Haxe, paths with spaces."""
import importlib
import json
import shutil
import unittest
from pathlib import Path
from types import SimpleNamespace
import test_toolchain
from test_toolchain import cli


class Filesystem(unittest.TestCase):
    setUpClass = classmethod(test_toolchain.Toolchain.setUpClass.__func__)
    tearDownClass = classmethod(test_toolchain.Toolchain.tearDownClass.__func__)
    invoke = test_toolchain.Toolchain.invoke

    def new(self, name, kind='addon'):
        root = self.root / (name + ' with spaces')
        cli.command_new(SimpleNamespace(name=name, directory=str(root), project_type=kind,
                                        title='A Test', base='sandbox', category='other', maps=''))
        # Explicit compatibility fixtures; current scaffolds need no empty helper.
        helper = root / 'src/shared/SharedMain.hx'
        helper.parent.mkdir(parents=True)
        helper.write_text('package shared; class SharedMain { public static function init():Void {} }')
        if kind == 'addon':
            for realm in ('server', 'client'):
                self.entry(root, f'lua/autorun/{realm}/{name}_{realm}.hx', 'shared.SharedMain.init();')
        return root

    def entry(self, root, relative, body):
        path = root / 'src' / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('package; class Main { static function main() { ' + body + ' } }', encoding='utf-8')
        return path

    def test_paths_helpers_precedence_shared_and_runtime(self):
        root = self.new('mirror')
        (root / 'src/shared/SharedMain.hx').write_text('package shared; class SharedMain { public static function init() { lua.Lua.print("EXTERNAL_SOURCE_SENTINEL"); } }')
        # The staged Main must also take precedence over an ordinary project Main.
        (root / 'src/Main.hx').write_text('this helper must never be compiled')
        self.entry(root, 'lua/mirror/debug.hx', 'shared.SharedMain.init(); #if gmod_server untyped __lua__("_G.realm = \'server\'"); #else untyped __lua__("_G.realm = \'client\'"); #end')
        for kind, context in (('entities', 'ENT'), ('weapons', 'SWEP')):
            self.entry(root, f'lua/{kind}/mirror_{kind}/shared.hx', f'untyped __lua__("{context}.PrintName = \'mirrored\'");')
            for name in ('init', 'cl_init'):
                self.entry(root, f'lua/{kind}/mirror_{kind}/{name}.hx', 'gmod.LuaScripts.include("shared.lua");')
        raw = root / 'lua/mirror/raw.lua'
        raw.parent.mkdir(parents=True)
        raw.write_text('return 42')
        self.invoke(root / 'src', 'build', '--package')
        self.invoke(root, 'doctor')
        package = root / 'dist/mirror'
        self.assertTrue((package / 'lua/mirror/debug.lua').is_file())
        self.assertFalse(list(package.rglob('SharedMain.lua')))
        self.assertIn('EXTERNAL_SOURCE_SENTINEL', (package / 'lua/mirror/debug.lua').read_text())
        transfer = (package / 'lua/autorun/server/mirror_hxgmod_transfer.lua').read_text()
        self.assertIn('AddCSLuaFile("mirror/debug.lua")', transfer)
        self.assertIn('AddCSLuaFile("mirror/raw.lua")', transfer)
        self.assertNotIn('AddCSLuaFile("entities/mirror_entities/init.lua")', transfer)
        for backend in ('lua51', 'luajit21'):
            try:
                runtime = importlib.import_module('lupa.' + backend).LuaRuntime(unpack_returned_tuples=True)
            except ModuleNotFoundError:
                print(f'OPTIONAL RUNTIME CHECK SKIPPED: {backend}')
                continue
            for server in (True, False):
                runtime.execute('SERVER = ' + str(server).lower() + '; CLIENT = not SERVER; ENT = {}; SWEP = {}; sent = {}; function AddCSLuaFile(p) sent[p]=true end')
                runtime.execute(transfer)
                runtime.execute((package / 'lua/mirror/debug.lua').read_text())
                self.assertEqual(runtime.globals().realm, 'server' if server else 'client')
                for kind, context in (('entities', 'ENT'), ('weapons', 'SWEP')):
                    folder = package / f'lua/{kind}/mirror_{kind}'
                    runtime.globals().include = lambda filename, folder=folder: runtime.execute((folder / filename).read_text())
                    runtime.execute((folder / ('init.lua' if server else 'cl_init.lua')).read_text())
                    self.assertEqual(runtime.globals()[context].PrintName, 'mirrored')
                self.assertIsNone(runtime.globals()._hx_array_mt)
        (root / 'src/lua/mirror/debug.hx').unlink()
        self.invoke(root, 'build', '--package')
        self.assertFalse((package / 'lua/mirror/debug.lua').exists())

    def test_realm_inference_and_strict_rejection(self):
        cases = {'lua/autorun/server/startup.hx':'server', 'lua/autorun/client/startup.hx':'client',
                 'lua/entities/e/init.hx':'server', 'lua/entities/e/cl_init.hx':'client',
                 'lua/weapons/w/shared.hx':'shared', 'gamemode/init.hx':'server',
                 'gamemode/cl_init.hx':'client', 'gamemode/shared.hx':'shared', 'lua/a/debug.hx':'shared'}
        for path, realm in cases.items():
            self.assertEqual(cli.infer_realm(path), realm)
        root = self.new('strict')
        source = self.entry(root, 'lua/autorun/server/api.hx', 'gmod.UtilLib.addNetworkString("test");')
        self.invoke(root, 'build', '--package')
        source.rename(root / 'src/lua/autorun/client/api.hx')
        result = self.invoke(root, 'build', okay=False)
        self.assertIn('addNetworkString', result.stdout + result.stderr)
        self.invoke(root, 'package', okay=False)
        self.assertTrue((root / 'dist/strict/lua/autorun/server/api.lua').is_file())

    def test_gamemode_layout_and_loaders(self):
        root = self.new('mirror_mode', 'gamemode')
        for kind in ('entities', 'weapons'):
            for file in ('init', 'cl_init', 'shared'):
                self.entry(root, f'gamemode-root/entities/{kind}/mirror_test/{file}.hx', '')
        self.invoke(root, 'build', '--package')
        package = root / 'dist/mirror_mode'
        self.assertTrue((package / 'mirror_mode.txt').is_file())
        for kind in ('entities', 'weapons'):
            for file in ('init', 'cl_init', 'shared'):
                self.assertTrue((package / f'entities/{kind}/mirror_test/{file}.lua').is_file())
        init = (package / 'gamemode/init.lua').read_text()
        self.assertIn('AddCSLuaFile("mirror_mode/gamemode/shared.lua")', init)
        self.assertIn('AddCSLuaFile("entities/mirror_test/cl_init.lua")', init)
        self.assertIn('AddCSLuaFile("weapons/mirror_test/shared.lua")', init)
        self.assertIn('DeriveGamemode', (package / 'gamemode/shared.lua').read_text())
        for backend in ('lua51', 'luajit21'):
            try:
                runtime = importlib.import_module('lupa.' + backend).LuaRuntime()
            except ModuleNotFoundError:
                continue
            for server in (True, False):
                runtime.execute('SERVER=' + str(server).lower() + '; function AddCSLuaFile(p) end; function DeriveGamemode(n) base=n end')
                runtime.globals().include = lambda filename: runtime.execute((package / 'gamemode' / filename).read_text())
                runtime.execute((package / 'gamemode' / ('init.lua' if server else 'cl_init.lua')).read_text())
                self.assertEqual(runtime.globals().base, 'sandbox')

    def test_collisions_doctor_partial_and_freshness(self):
        root = self.new('mirror_collision')
        self.invoke(root, 'build', '--package')
        old = (root / 'dist/mirror_collision/lua/autorun/server/mirror_collision_server.lua').read_bytes()
        raw = root / 'lua/autorun/server/MIRROR_COLLISION_SERVER.lua'
        raw.parent.mkdir(parents=True)
        raw.write_text('collision')
        self.assertIn('collision', self.invoke(root, 'doctor', okay=False).stderr)
        self.invoke(root, 'build', okay=False)
        self.invoke(root, 'package', okay=False)
        self.assertEqual((root / 'dist/mirror_collision/lua/autorun/server/mirror_collision_server.lua').read_bytes(), old)
        raw.unlink()
        self.invoke(root, 'build', 'server')
        self.invoke(root, 'package', okay=False)
        self.invoke(root, 'build', '--package')
        source = root / 'src/shared/SharedMain.hx'
        source.write_text(source.read_text() + '\n// changed')
        self.invoke(root, 'package', okay=False)
        config = cli.load_config(root)
        config['entities'] = {'old': 'shared.Old'}
        cli.save_config(root, config)
        self.assertIn('remove configured targets', self.invoke(root, 'doctor', okay=False).stderr)

    def test_reserved_paths_and_file_directory_collision(self):
        root = self.new('reserved')
        config = cli.load_config(root)
        source = self.entry(root, 'lua/autorun/server/reserved_hxgmod_transfer.hx', '')
        with self.assertRaisesRegex(cli.HxGModError, 'collision'):
            cli.mirror_plan(root, config)
        source.unlink()
        self.entry(root, 'lua/entities/thing.hx', '')
        self.entry(root, 'lua/entities/thing/init.hx', '')
        with self.assertRaisesRegex(cli.HxGModError, 'collision'):
            cli.mirror_plan(root, config)


if __name__ == '__main__':
    unittest.main()
