package gmod;

/**
 * Binding for Garry's Mod's global `hook` library.
 *
 * This is handwritten for now. Later, bindings like this will be
 * generated automatically from the GLua API data.
 */
@:native("hook")
extern class Hook
{
    /**
     * Adds a callback to a Garry's Mod hook.
     */
    @:native("Add")
    public static function add(
        eventName:String,
        identifier:String,
        callback:Dynamic
    ):Void;
}
