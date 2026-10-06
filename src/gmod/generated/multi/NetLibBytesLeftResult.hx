package gmod.generated.multi;

/**
 * Multiple return values from net.BytesLeft.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class NetLibBytesLeftResult
{
    /**
     * The amount of data left to read in the current net message in **bytes**. Returns `nil` if no net message has been started.
     */
    public var value1:Float;

    /**
     * The amount of data left to read in the current net message in **bits**. Returns `nil` if no net message has been started.
     */
    public var value2:Float;

}
