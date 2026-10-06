package gmod.generated.multi;

/**
 * Multiple return values from net.BytesWritten.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class NetLibBytesWrittenResult
{
    /**
     * The amount of **bytes** written to the current net message. Returns `nil` if no net message has been started.
     */
    public var value1:Float;

    /**
     * The amount of **bits** written to the current net message. Returns `nil` if no net message has been started.
     */
    public var value2:Float;

}
