package gmod.generated.multi;

/**
 * Multiple return values from _G.pcall.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class GlobalLibPcallResult
{
    /**
     * If the function had no errors occur within it.
     */
    public var value1:Bool;

    /**
     * If an error occurred, this will be a string containing the error message. Otherwise, this will be the return values of the function passed in.
     */
    public var value2:Dynamic;

}
