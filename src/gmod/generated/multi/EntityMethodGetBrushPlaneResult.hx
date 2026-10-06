package gmod.generated.multi;

/**
 * Multiple return values from Entity.GetBrushPlane.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class EntityMethodGetBrushPlaneResult
{
    /**
     * The origin of the plane. This will be either the first vertex's position (if available) or the plane's normal multiplied by the plane's distance.
     */
    public var value1:Vector;

    /**
     * The normal of the plane.
     */
    public var value2:Vector;

    /**
     * The "distance" of the plane. The distance is the dot product of the plane's normal and the point it was initialized with.
     */
    public var value3:Float;

}
