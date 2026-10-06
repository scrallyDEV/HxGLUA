package gmod.generated.multi;

/**
 * Multiple return values from Entity.GetHitBoxBounds.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class EntityMethodGetHitBoxBoundsResult
{
    /**
     * Hit box mins. Will be nil if the hit box index was out of range.
     */
    public var value1:Vector;

    /**
     * Hit box maxs. Will be nil if the hit box index was out of range.
     */
    public var value2:Vector;

}
