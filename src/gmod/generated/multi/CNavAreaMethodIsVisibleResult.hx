package gmod.generated.multi;

/**
 * Multiple return values from CNavArea.IsVisible.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class CNavAreaMethodIsVisibleResult
{
    /**
     * Whether we can be seen or not.
     */
    public var value1:Bool;

    /**
     * If we can be seen, this is returned with either the center or one of the corners of the Nav Area.
     */
    public var value2:Vector;

}
