"""Offline regression suite. Run: python -m unittest discover -s tests -v

Haxe/haxelib are required. Lupa is optional for executable Lua 5.1/LuaJIT checks.
Uses a disposable local haxelib repository and never changes global registration.
"""
import importlib
import json
import os
import shutil
import subprocess
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import hxgmod as cli


class Toolchain(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.context = cli.staging_directory(cli.SDK_ROOT / '.work', 'tests-')
        cls.root = cls.context.__enter__()
        cli.run(['haxelib', 'newrepo'], cls.root)
        cli.run(['haxelib', 'dev', 'hxgmod', str(cli.SDK_ROOT)], cls.root)

    @classmethod
    def tearDownClass(cls):
        cls.context.__exit__(None, None, None)

    def new(self, name, kind='addon'):
        root = self.root / (name + ' with spaces')
        cli.command_new(SimpleNamespace(name=name, directory=str(root), project_type=kind,
                                        title='A Test', base='sandbox', category='other', maps=''))
        # Keep the original regression cases exercising the supported legacy path.
        config = cli.load_config(root)
        config['source_layout'] = 'legacy'
        cli.save_config(root, config)
        shutil.rmtree(root / 'src')
        cli.scaffold_sources(root)
        for realm in ('server', 'client'):
            (root / f'build-{realm}.hxml').write_text(cli.build_hxml(realm))
        return root

    def invoke(self, root, *args, okay=True):
        environment = os.environ.copy()
        environment['PATH'] = str(cli.SDK_ROOT) + os.pathsep + environment.get('PATH', '')
        result = subprocess.run([sys.executable, str(cli.SDK_ROOT / 'tools/hxgmod.py'), *args], cwd=root, capture_output=True, text=True, env=environment)
        if okay:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_01_addon_build_package_install_and_stale(self):
        root = self.new('test_addon')
        (root / 'src/shared/SharedMain.hx').write_text('package shared; class SharedMain { public static function init() { lua.Lua.print("EXTERNAL_SOURCE_SENTINEL"); } }')
        raw = root / 'lua/helpers/raw.lua'
        raw.parent.mkdir(parents=True)
        raw.write_text('return 42\n')
        self.invoke(root / 'src', 'build', '--package')
        package = root / 'dist/test_addon'
        self.assertIn('EXTERNAL_SOURCE_SENTINEL', (package / 'lua/autorun/server/test_addon_server.lua').read_text())
        self.assertIn('autorun/client/test_addon_client.lua', (package / 'lua/autorun/server/test_addon_server.lua').read_text())
        self.assertEqual((package / 'lua/helpers/raw.lua').read_text(), 'return 42\n')
        self.assertFalse((root / 'src/gmod').exists())
        install_dir = self.root / 'Garrys Mod/garrysmod/addons'
        self.invoke(root, 'install', str(install_dir))
        self.invoke(root, 'install', str(install_dir))
        installed = install_dir / 'test_addon/lua/helpers/raw.lua'
        installed.write_text('user edit')
        self.assertIn('untracked or modified', self.invoke(root, 'install', str(install_dir), okay=False).stderr)
        self.assertEqual(installed.read_text(), 'user edit')
        raw.write_text('return 43\n')
        self.assertIn('stale', self.invoke(root, 'package', okay=False).stderr)
        self.assertEqual((package / 'lua/helpers/raw.lua').read_text(), 'return 42\n')
        self.invoke(root, 'build', 'server', '--package', okay=False)
        self.invoke(root, 'build', 'server')
        self.invoke(root, 'package', okay=False)
        self.invoke(root, 'clean')
        self.assertFalse((root / 'build').exists())
        self.assertTrue((root / 'src/shared/SharedMain.hx').exists())

    def test_02_gamemode_targets_and_runtime(self):
        root = self.new('test_mode', 'gamemode')
        config = cli.load_config(root)
        config['entities'] = {'test_entity': 'shared.LearningEntity', 'test_bot': 'shared.LearningNextBot'}
        config['weapons'] = {'weapon_test': 'shared.LearningWeapon'}
        cli.save_config(root, config)
        for name in ('LearningEntity', 'LearningNextBot', 'LearningWeapon'):
            shutil.copy2(cli.SDK_ROOT / f'examples/learning/src/shared/{name}.hx', root / f'src/shared/{name}.hx')
        self.invoke(root, 'build', '--package')
        package = root / 'dist/test_mode'
        self.assertTrue((package / 'test_mode.txt').is_file())
        self.assertIn('DeriveGamemode("sandbox")', (package / 'gamemode/init.lua').read_text())
        for folder in ('entities/test_entity', 'entities/test_bot', 'weapons/weapon_test'):
            for name in ('init.lua', 'cl_init.lua'):
                self.assertTrue((package / 'entities' / folder / name).is_file())
        for backend in ('lua51', 'luajit21'):
            try:
                runtime = importlib.import_module('lupa.' + backend).LuaRuntime(unpack_returned_tuples=True)
            except ModuleNotFoundError:
                print(f'OPTIONAL RUNTIME CHECK SKIPPED: install lupa for {backend}')
                continue
            for server in (True, False):
                runtime.execute('SERVER = ' + str(server).lower() + '; CLIENT = not SERVER; function AddCSLuaFile(p) end; function DeriveGamemode(n) end')
                filename = 'init.lua' if server else 'cl_init.lua'
                runtime.execute((package / 'gamemode' / filename).read_text())
                runtime.execute('ENT = {}')
                runtime.execute((package / 'entities/entities/test_entity' / filename).read_text())
                entity = runtime.globals().ENT
                self.assertEqual(entity.PrintName, 'HxGMod Learning Entity')
                runtime.execute('ENT = {}; SWEP = {}')
                runtime.execute((package / 'entities/entities/test_bot' / filename).read_text())
                runtime.execute((package / 'entities/weapons/weapon_test' / filename).read_text())
                self.assertEqual(runtime.globals().SWEP.Base, 'weapon_base')
                self.assertEqual(runtime.globals().SWEP.Primary.Ammo, 'none')
                weapon = runtime.eval('{SetHoldType=function(s,v) s.hold=v end}')
                runtime.globals().SWEP.Initialize(weapon)
                runtime.globals().SWEP.PrimaryAttack(weapon)
                self.assertEqual(weapon.hold, 'melee')
                self.assertIsNone(runtime.globals()._hx_array_mt)
                obj = runtime.eval('''{SetModel=function(s,m) s.model=m end,
                    PhysicsInit=function(s,v) s.solid=v end,
                    SetMoveType=function(s,v) end, SetSolid=function(s,v) end,
                    GetPhysicsObject=function(s) return {IsValid=function() return true end, Wake=function() end} end,
                    DrawModel=function(s) s.drawn=true end}''')
                if server:
                    entity.Initialize(obj)
                    self.assertEqual(obj.model, 'models/props_c17/oildrum001.mdl')
                    self.assertEqual(obj.solid, 6)
                else:
                    entity.Draw(obj)
                    self.assertTrue(obj.drawn)
        # A failed build invalidates the old package inputs without destroying dist.
        (root / 'src/shared/LearningEntity.hx').write_text('invalid haxe')
        self.invoke(root, 'build', okay=False)
        self.invoke(root, 'package', okay=False)
        self.assertTrue((package / 'test_mode.txt').is_file())

    def test_03_collision_keeps_previous_package(self):
        root = self.new('collision')
        self.invoke(root, 'build', '--package')
        package = root / 'dist/collision/lua/autorun/server/collision_server.lua'
        before = package.read_bytes()
        raw = root / 'package-root/lua/autorun/server/collision_server.lua'
        raw.parent.mkdir(parents=True)
        raw.write_text('conflict')
        self.invoke(root, 'build')
        result = self.invoke(root, 'package', okay=False)
        self.assertIn('collision', result.stderr)
        self.assertEqual(package.read_bytes(), before)

    def test_04_names_and_config(self):
        for name in ('..', '.', '../escape', 'CON', 'con', 'foo/bar', 'x y', 'Upper', 'name.'):
            with self.assertRaises(cli.HxGModError):
                cli.valid_name(name)
        root = self.new('config')
        for invalid in ([], {'name':'valid', 'entities': []}, {'name':'valid', 'weapons': {'../x':'Main'}}, {'name':'valid','entities':{'x':'../Main'}}):
            cli.save_config(root, invalid)
            with self.assertRaises(cli.HxGModError):
                cli.load_config(root)

    def test_05_aliases_and_realm_checks(self):
        root = self.new('bindings')
        source = root / 'src/shared/SharedMain.hx'
        source.write_text('''package shared;
import gmod.Player; import gmod.PlayerEnum; import gmod.PlayerStruct;
import gmod.MaterialEnum; import gmod.ToolStruct; import gmod.ColorStruct;
import gmod.TraceResult; import gmod.ENTStruct; import gmod.SWEPStruct;
import gmod.DMG; import gmod.Hooks;
class SharedMain {
    static var p:Player; static var pe:PlayerEnum; static var ps:PlayerStruct;
    static var m:MaterialEnum; static var t:ToolStruct; static var c:ColorStruct;
    static var tr:TraceResult; static var ent:ENTStruct; static var wep:SWEPStruct;
    public static function init():Void { Hooks.initialize("smoke", () -> {}); }
}''')
        self.invoke(root, 'build')
        source.write_text('package shared; class SharedMain { public static function init() { gmod.PlayerLib.getAll(); } }')
        self.invoke(root, 'build')
        # Server-only entity API must not be exposed to a strict client build.
        source.write_text('package shared; class SharedMain { public static function init() { gmod.UtilLib.addNetworkString("x"); } }')
        self.invoke(root, 'build', 'server')
        result = self.invoke(root, 'build', 'client', okay=False)
        self.assertIn('addNetworkString', result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
