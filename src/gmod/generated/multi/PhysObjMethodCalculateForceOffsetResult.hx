package gmod.generated.multi;

/**
 * Multiple return values from PhysObj.CalculateForceOffset.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PhysObjMethodCalculateForceOffsetResult
{
    /**
     * The calculated linear impulse on the physics object's center of mass in `kg*source_unit/s`. (World frame)
     */
    public var linearImpulse:Vector;

    /**
     * The calculated angular impulse on the physics object's center of mass in `kg*m^2*degrees/s`. (Local frame)
     */
    public var angularImpulse:Vector;

}
