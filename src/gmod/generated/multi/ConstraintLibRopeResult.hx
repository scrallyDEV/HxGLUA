package gmod.generated.multi;

/**
 * Multiple return values from constraint.Rope.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class ConstraintLibRopeResult
{
    /**
     * The constraint entity ([phys_lengthconstraint](https://developer.valvesoftware.com/wiki/Phys_lengthconstraint)). Will be a `keyframe_rope` if you are roping to the same bone on ...
     */
    public var constraint:Entity;

    /**
     * The rope entity. Will return `nil` if `constraint` return value is a [keyframe_rope](https://developer.valvesoftware.com/wiki/Keyframe_rope) or if the constraint could not be cr...
     */
    public var rope:Entity;

}
