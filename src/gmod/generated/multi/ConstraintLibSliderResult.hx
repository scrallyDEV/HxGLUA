package gmod.generated.multi;

/**
 * Multiple return values from constraint.Slider.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class ConstraintLibSliderResult
{
    /**
     * The created constraint entity. ([phys_slideconstraint](https://developer.valvesoftware.com/wiki/Phys_slideconstraint)) Will return `false` if the constraint could not be created.
     */
    public var value1:Entity;

    /**
     * The created rope. ([keyframe_rope](https://developer.valvesoftware.com/wiki/Keyframe_rope)) Will return `nil` if the constraint or the rope could not be created.
     */
    public var value2:Entity;

}
