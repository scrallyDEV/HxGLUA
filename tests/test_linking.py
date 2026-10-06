"""Real compiler and Lua 5.1/LuaJIT checks for the filesystem module linker."""
import importlib
import unittest
import test_filesystem
from test_toolchain import cli


class Linking(unittest.TestCase):
    setUpClass = classmethod(test_filesystem.Filesystem.setUpClass.__func__)
    tearDownClass = classmethod(test_filesystem.Filesystem.tearDownClass.__func__)
    new = test_filesystem.Filesystem.new
    entry = test_filesystem.Filesystem.entry
    invoke = test_filesystem.Filesystem.invoke
    def module(self, root, path, text):
        file = root / 'src/lua' / path
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(text, encoding='utf-8')
        return file

    def test_linked_state_and_order(self):
        root = self.new('linked')
        self.module(root, 'player/PlayerVar.hx', '''package player;
class PlayerVar {
 public static var health:Int = 100;
 public static function main() { untyped __lua__("_G.playerLoads = (_G.playerLoads or 0) + 1"); }
 public static function someFunction():Int {
  lua.Lua.print("PLAYER_IMPLEMENTATION_SENTINEL");
  return ++health;
 }
}''')
        self.module(root, 'enemy/Enemy.hx', '''package enemy;
import player.PlayerVar;
class Enemy {
 public static var initial = PlayerVar.health;
 public static function run():Int { return PlayerVar.someFunction(); }
}''')
        self.entry(root, 'lua/autorun/server/caller.hx', '''
untyped __lua__("_G.first = {0}", enemy.Enemy.run());
untyped __lua__("_G.second = {0}", player.PlayerVar.someFunction());
untyped __lua__("_G.initial = {0}", enemy.Enemy.initial);
''')
        (root / 'src/shared/Bridge.hx').write_text('package shared; class Bridge { public static function bump() { return player.PlayerVar.someFunction(); } }')
        self.entry(root, 'lua/helpercaller.hx', 'untyped __lua__("_G.third = {0}", shared.Bridge.bump());')
        self.invoke(root, 'build', '--package')
        folder = root / 'dist/linked/lua'
        self.assertIn('PLAYER_IMPLEMENTATION_SENTINEL', (folder / 'player/PlayerVar.lua').read_text())
        self.assertNotIn('PLAYER_IMPLEMENTATION_SENTINEL', (folder / 'enemy/Enemy.lua').read_text())
        self.assertNotIn('PLAYER_IMPLEMENTATION_SENTINEL', (folder / 'autorun/server/caller.lua').read_text())
        for backend in ('lua51', 'luajit21'):
            runtime = importlib.import_module('lupa.' + backend).LuaRuntime()
            runtime.execute('SERVER=true; CLIENT=false')
            loads = []
            def include(path):
                loads.append(path)
                return runtime.execute((folder / path).read_text())
            runtime.globals().include = include
            include('autorun/server/caller.lua')
            self.assertEqual(runtime.globals().first, 101)
            self.assertEqual(runtime.globals().second, 102)
            self.assertEqual(runtime.globals().initial, 100)
            include('autorun/server/caller.lua')
            self.assertEqual(runtime.globals().second, 104)
            self.assertEqual(loads.count('player/PlayerVar.lua'), 1)
            include('player/PlayerVar.lua')
            self.assertEqual(runtime.globals().playerLoads, 1)
            include('helpercaller.lua')
            self.assertEqual(runtime.globals().third, 105)

    def test_types_helpers_inline_and_client_guard(self):
        root = self.new('types_link')
        self.module(root, 'model/Counter.hx', '''package model;
enum Choice { One; More(n:Int); }
class Counter {
 public var value:Int;
 public function new(v:Int) { value = v; }
 public function get():Int { return value; }
 public static inline function marker():String { return "INLINE_BODY_SENTINEL"; }
 public static function help():Int { return shared.Helper.number(); }
}
''')
        (root / 'src/shared/Helper.hx').write_text('package shared; class Helper { public static function number():Int { lua.Lua.print("PRIVATE_HELPER_SENTINEL"); return 7; } }')
        self.module(root, 'client/Only.hx', 'package client; class Only { public static var value = 42; }')
        self.module(root, 'Use.hx', '''import model.Counter;
import model.Counter.Choice;
class Use extends Counter {
 public function new() { super(9); }
 public static function main() {
  var obj = new Use();
  var choice = Choice.More(Counter.help());
  untyped __lua__("_G.objectValue = {0}", obj.get());
  untyped __lua__("_G.marker = {0}", Counter.marker());
  switch choice { case More(n): untyped __lua__("_G.enumValue = {0}", n); default: }
  #if gmod_client untyped __lua__("_G.clientValue = {0}", client.Only.value); #end
 }
}''')
        self.invoke(root, 'build', '--package')
        folder = root / 'dist/types_link/lua'
        text = (folder / 'Use.lua').read_text()
        self.assertNotIn('INLINE_BODY_SENTINEL', text)
        self.assertNotIn('PRIVATE_HELPER_SENTINEL', text)
        for backend in ('lua51', 'luajit21'):
            for server in (True, False):
                runtime = importlib.import_module('lupa.' + backend).LuaRuntime()
                runtime.execute('SERVER=' + str(server).lower() + '; CLIENT=not SERVER')
                loads = []
                def include(path):
                    loads.append(path)
                    return runtime.execute((folder / path).read_text())
                runtime.globals().include = include
                include('Use.lua')
                self.assertEqual(runtime.globals().objectValue, 9)
                self.assertEqual(runtime.globals().enumValue, 7)
                self.assertEqual(runtime.globals().marker, 'INLINE_BODY_SENTINEL')
                self.assertEqual('client/Only.lua' in loads, not server)
                include('client/Only.lua')
                self.assertIsNone(runtime.globals()._hx_array_mt)

    def test_cycle_and_realm_errors(self):
        root = self.new('bad_link')
        a = self.module(root, 'A.hx', 'class A { public static function call() { B.call(); } }')
        self.module(root, 'B.hx', 'class B { public static function call() { A.call(); } }')
        result = self.invoke(root, 'build', okay=False)
        self.assertIn('cycle', result.stdout + result.stderr)
        (root / 'src/lua/B.hx').unlink()
        self.module(root, 'client/Only.hx', 'package client; class Only { public static var value = 1; }')
        a.write_text('class A { public static var value = client.Only.value; }')
        result = self.invoke(root, 'build', okay=False)
        self.assertIn('cannot load', result.stdout + result.stderr)
        self.invoke(root, 'package', okay=False)
        a.unlink()
        self.module(root, 'server/OnlyServer.hx', 'package server; class OnlyServer { public static var value = 1; }')
        self.module(root, 'client/Only.hx', 'package client; class Only { public static var value = server.OnlyServer.value; }')
        result = self.invoke(root, 'build', okay=False)
        self.assertIn('cannot load', result.stdout + result.stderr)

    def test_gamemode_dependencies(self):
        root = self.new('linked_mode', 'gamemode')
        (root / 'src/gamemode-root/gamemode/State.hx').write_text('package gamemode; class State { public static var value = 23; }')
        self.entry(root, 'gamemode-root/gamemode/init.hx', 'untyped __lua__("_G.answer = {0}", gamemode.State.value);')
        self.invoke(root, 'build', '--package')
        package = root / 'dist/linked_mode'
        for backend in ('lua51', 'luajit21'):
            runtime = importlib.import_module('lupa.' + backend).LuaRuntime()
            runtime.execute('SERVER=true; CLIENT=false; sent={}; function AddCSLuaFile(p) sent[p]=true end')
            loads = []
            def include(path):
                loads.append(path)
                self.assertTrue(path.startswith('linked_mode/'))
                return runtime.execute((package / path[len('linked_mode/'):]).read_text())
            runtime.globals().include = include
            runtime.execute((package / 'gamemode/init.lua').read_text())
            self.assertEqual(runtime.globals().answer, 23)
            self.assertEqual(loads, ['linked_mode/gamemode/State.lua'])
            self.assertTrue(runtime.globals().sent['linked_mode/gamemode/State.lua'])

    def test_namespace_isolation_and_failed_module(self):
        packages = []
        for name in ('first_project', 'second_project'):
            root = self.new(name)
            config = cli.load_config(root)
            config['name'] = 'same_name'
            cli.save_config(root, config)
            self.module(root, 'State.hx', 'class State { public static var n = 0; public static function step() { return ++n; } }')
            self.module(root, 'Broken.hx', 'class Broken { public static function main() { untyped __lua__("_G.attempts = (_G.attempts or 0) + 1; error(\'module failed\')"); } }')
            self.entry(root, 'lua/call.hx', 'untyped __lua__("_G.answer = {0}", State.step());')
            self.invoke(root, 'build', '--package')
            packages.append(root / 'dist/same_name/lua')
        for backend in ('lua51', 'luajit21'):
            runtime = importlib.import_module('lupa.' + backend).LuaRuntime()
            runtime.execute('SERVER=true; CLIENT=false')
            for folder in packages:
                runtime.globals().include = lambda path: runtime.execute((folder / path).read_text())
                runtime.execute((folder / 'call.lua').read_text())
                self.assertEqual(runtime.globals().answer, 1)
            for _ in range(2):
                with self.assertRaisesRegex(Exception, 'module failed'):
                    runtime.execute((folder / 'Broken.lua').read_text())
            self.assertEqual(runtime.globals().attempts, 1)


if __name__ == '__main__':
    unittest.main()
