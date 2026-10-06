package gmod.generated.multi;

/**
 * Multiple return values from constraint.Motor.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class ConstraintLibMotorResult
{
    /**
     * The created constraint. ([phys_torque](https://developer.valvesoftware.com/wiki/Phys_torque)) Will return `false` if the constraint could not be created.
     */
    public var value1:Entity;

    /**
     * The created axis constraint. ([phys_hinge](https://developer.valvesoftware.com/wiki/Phys_hinge)) Will return `nil` if the constraint could not be created.
     */
    public var value2:Entity;

}
