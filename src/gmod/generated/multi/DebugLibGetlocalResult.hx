package gmod.generated.multi;

/**
 * Multiple return values from debug.getlocal.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class DebugLibGetlocalResult
{
    /**
     * The name of the variable. Sometimes this will be `(*temporary)` if the local variable had no name. Variables with names starting with **(** are **internal variables**.
     */
    public var value1:String;

    /**
     * The value of the local variable.
     */
    public var value2:Dynamic;

}
