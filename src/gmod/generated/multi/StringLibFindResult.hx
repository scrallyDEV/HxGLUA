package gmod.generated.multi;

/**
 * Multiple return values from string.find.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class StringLibFindResult
{
    /**
     * Starting position of the found text, or nil if the text wasn't found
     */
    public var value1:Float;

    /**
     * Ending position of found text, or nil if the text wasn't found
     */
    public var value2:Float;

    /**
     * Matched text for each group if patterns are enabled and used, or nil if the text wasn't found
     */
    public var value3:String;

}
