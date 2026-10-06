package gmod.generated.multi;

/**
 * Multiple return values from _G.next.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class GlobalLibNextResult
{
    /**
     * The next key for the table. If the previous key was nil, this will be the first key in the table. If the previous key was the last key in the table, this will be nil.
     */
    public var value1:Dynamic;

    /**
     * The value associated with that key. If the previous key was the last key in the table, this will be nil.
     */
    public var value2:Dynamic;

}
