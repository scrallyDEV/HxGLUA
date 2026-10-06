package gmod.generated.multi;

/**
 * Multiple return values from player.Iterator.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PlayerLibIteratorResult
{
    /**
     * The Iterator Function from Global.ipairs.
     */
    public var value1:Dynamic;

    /**
     * Table of all existing Player. This is a cached copy of player.GetAll. This table is intended to be read-only. Modifying the return table will affect all subsequent calls to this...
     */
    public var value2:gmod.NativeSequence<Player>;

    /**
     * The starting index for the table of players. 			This is always `0` and is returned for the benefit of [Generic For-Loops](https://www.lua.org/pil/4.3.5.html).
     */
    public var value3:Float;

}
