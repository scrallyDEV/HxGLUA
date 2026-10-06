package gmod.generated.multi;

/**
 * Multiple return values from debug.gethook.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class DebugLibGethookResult
{
    /**
     * Hook function.
     */
    public var value1:Dynamic;

    /**
     * Hook mask. This is reversed of the debug.sethook mask ("clr" would be "rlc").
     */
    public var value2:String;

    /**
     * Hook count.
     */
    public var value3:Float;

}
