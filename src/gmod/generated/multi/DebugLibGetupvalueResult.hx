package gmod.generated.multi;

/**
 * Multiple return values from debug.getupvalue.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class DebugLibGetupvalueResult
{
    /**
     * Name of the upvalue. Will be nil if the index was out of range (< 1 or > debug.getinfo.nups), or the function was defined in C.
     */
    public var value1:String;

    /**
     * Value of the upvalue.
     */
    public var value2:Dynamic;

}
