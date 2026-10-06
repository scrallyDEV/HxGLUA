package gmod.generated.multi;

/**
 * Multiple return values from _G.assert.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class GlobalLibAssertResult
{
    /**
     * If successful, returns the first argument.
     */
    public var value1:Dynamic;

    /**
     * If successful, returns the error message. This will be nil if the second argument wasn't specified. Since the second argument is only type-checked if the assertion fails, this d...
     */
    public var value2:Dynamic;

    /**
     * Returns any arguments past the error message.
     */
    public var value3:Dynamic;

}
