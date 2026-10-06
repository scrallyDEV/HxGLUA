package;

import hx_learning.enemy.Enemy;
import hx_learning.player.PlayerVar;

class Main {
    static function main():Void {
        lua.Lua.print("Enemy call: " + Enemy.checkPlayer()); // 1
        lua.Lua.print("Direct call: " + PlayerVar.someFunction()); // 2
        lua.Lua.print("Shared calls: " + PlayerVar.calls); // 2
    }
}
