package gmod.generated.multi;

/**
 * Multiple return values from constraint.Pulley.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class ConstraintLibPulleyResult
{
    /**
     * The created constraint. ([phys_pulleyconstraint](https://developer.valvesoftware.com/wiki/Phys_pulleyconstraint)) Will return `false` if the constraint could not be created.
     */
    public var value1:Entity;

    /**
     * The first rope segment. ([keyframe_rope](https://developer.valvesoftware.com/wiki/Keyframe_rope)) Will return `nil` if the constraint or this rope segment could not be created.
     */
    public var value2:Entity;

    /**
     * The second rope segment. ([keyframe_rope](https://developer.valvesoftware.com/wiki/Keyframe_rope)) Will return `nil` if the constraint or this rope segment could not be created.
     */
    public var value3:Entity;

    /**
     * The third rope segment. ([keyframe_rope](https://developer.valvesoftware.com/wiki/Keyframe_rope)) Will return `nil` if the constraint or this rope segment could not be created.
     */
    public var value4:Entity;

}
