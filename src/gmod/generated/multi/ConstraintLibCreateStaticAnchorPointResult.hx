package gmod.generated.multi;

/**
 * Multiple return values from constraint.CreateStaticAnchorPoint.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class ConstraintLibCreateStaticAnchorPointResult
{
    /**
     * The anchor entity. (`gmod_anchor`)
     */
    public var value1:Entity;

    /**
     * The achor entity's physics object. (Entity:GetPhysicsObject)
     */
    public var value2:PhysObj;

    /**
     * Always `0`.
     */
    public var value3:Float;

    /**
     * Always `vector_zero`.
     */
    public var value4:Vector;

}
