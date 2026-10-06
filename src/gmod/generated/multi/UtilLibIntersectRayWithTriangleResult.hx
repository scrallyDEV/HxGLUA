package gmod.generated.multi;

/**
 * Multiple return values from util.IntersectRayWithTriangle.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class UtilLibIntersectRayWithTriangleResult
{
    /**
     * The position of intersection, `nil` if not hit.
     */
    public var value1:Vector;

    /**
     * The fraction of start position to end position in range of [0,1] to the hit point, if there was a hit. i.e. 0.5 would be a hit in the exact middle of start and end positions.
     */
    public var value2:Float;

}
