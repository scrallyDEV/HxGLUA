package gmod.generated.multi;

/**
 * Multiple return values from constraint.Winch.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class ConstraintLibWinchResult
{
    /**
     * The created constraint. ([phys_spring](https://developer.valvesoftware.com/wiki/Phys_spring)) Can return `nil`. Will return `false` if the constraint could not be created.
     */
    public var value1:Entity;

    /**
     * The created rope. ([keyframe_rope](https://developer.valvesoftware.com/wiki/Keyframe_rope)) Will return `nil` if the constraint could not be created.
     */
    public var value2:Entity;

    /**
     * The winch controller. (`gmod_winch_controller`) Can return `nil`.
     */
    public var value3:Entity;

}
