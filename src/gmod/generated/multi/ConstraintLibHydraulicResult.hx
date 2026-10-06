package gmod.generated.multi;

/**
 * Multiple return values from constraint.Hydraulic.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class ConstraintLibHydraulicResult
{
    /**
     * The created constraint. ([phys_spring](https://developer.valvesoftware.com/wiki/Phys_spring)) Will return `false` if the constraint could not be created.
     */
    public var value1:Entity;

    /**
     * The created rope. ([keyframe_rope](https://developer.valvesoftware.com/wiki/Keyframe_rope)) Will return `nil` if the constraint could not be created.
     */
    public var value2:Entity;

    /**
     * The muscle controller. (`gmod_winch_controller`) Will return `nil` if the constraint could not be created.
     */
    public var value3:Entity;

    /**
     * The slider ([phys_slideconstraint](https://developer.valvesoftware.com/wiki/Phys_slideconstraint)) if `fixed` was exactly `1`. Will return nil otherwise, or if the constraint co...
     */
    public var value4:Entity;

}
