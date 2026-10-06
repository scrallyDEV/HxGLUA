package gmod.generated.multi;

/**
 * Multiple return values from ents.Iterator.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class EntsLibIteratorResult
{
    /**
     * The Iterator Function from Global.ipairs.
     */
    public var value1:Dynamic;

    /**
     * Table of all existing Entity. This is a cached copy of ents.GetAll. This table is intended to be read-only. Modifying the return table will affect all subsequent calls to this f...
     */
    public var value2:gmod.NativeSequence<Entity>;

    /**
     * The starting index for the table of players. 			This is always `0` and is returned for the benefit of [Generic For-Loops](https://www.lua.org/pil/4.3.5.html).
     */
    public var value3:Float;

}
