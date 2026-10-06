package gmod.generated.multi;

/**
 * Multiple return values from PhysObj.CalculateVelocityOffset.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PhysObjMethodCalculateVelocityOffsetResult
{
    /**
     * The calculated linear velocity from the impulse on the physics object's center of mass in `source_unit/s`. (World frame)
     */
    public var value1:Vector;

    /**
     * The calculated angular velocity from the impulse on the physics object's center of mass in `degrees/s`. (Local frame)
     */
    public var value2:Vector;

}
