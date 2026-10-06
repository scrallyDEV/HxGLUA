package autorun.server;

class HxLearningHello {
    public static function main():Void {
        gmod.ConcommandLib.add("hx_learning_hello", function(ply, command, args, text):Void {
            lua.Lua.print("Hello from hx_learning_hello");
        });
    }
}

