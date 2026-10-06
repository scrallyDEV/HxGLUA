package autorun.server;

class HxLearningReady {
    public static function main():Void {
        gmod.Hook.add("Initialize", "hx_learning_ready", function():Void {
            lua.Lua.print("Initialized");
        });
    }
}

