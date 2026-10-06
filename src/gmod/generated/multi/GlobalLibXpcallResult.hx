package gmod.generated.multi;

/**
 * Multiple return values from _G.xpcall.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class GlobalLibXpcallResult
{
    /**
     * Status of the execution; `true` for success, `false` for failure.
     */
    public var value1:Bool;

    /**
     * The returns of the first function if execution succeeded, otherwise the **first** return value of the error callback.
     */
    public var value2:Dynamic;

}
