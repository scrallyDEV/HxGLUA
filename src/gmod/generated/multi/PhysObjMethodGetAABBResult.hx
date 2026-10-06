package gmod.generated.multi;

/**
 * Multiple return values from PhysObj.GetAABB.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PhysObjMethodGetAABBResult
{
    /**
     * The minimum extents of the bounding box, or `nil` for runtime generated physics object.
     */
    public var value1:Null<Vector>;

    /**
     * The maximum extents of the bounding box.
     */
    public var value2:Vector;

}
