package gmod.generated.multi;

/**
 * Multiple return values from utf8.len.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class Utf8LibLenResult
{
    /**
     * The number of UTF-8 characters in the string. If there are invalid bytes, this will be false.
     */
    public var value1:Float;

    /**
     * The position of the first invalid byte. If there were no invalid bytes, this will be nil.
     */
    public var value2:Float;

}
