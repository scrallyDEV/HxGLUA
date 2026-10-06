package gmod.generated.multi;

/**
 * Multiple return values from duplicator.CreateConstraintFromTable.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class DuplicatorLibCreateConstraintFromTableResult
{
    /**
     * The newly created constraint entity, if any. For example, an entity of class `phys_pulleyconstraint` or `phys_spring`, etc., the functional entity of the constraint.
     */
    public var value1:Entity;

    /**
     * The second constraint related entity, if any. For a most constraints, this would be a `keyframe_rope` for the visual part of a constraint.
     */
    public var value2:Entity;

    /**
     * The third constraint related entity, if any. For example, a Hydraulic constraint would return the `gmod_winch_controller` entity here. A pulley would have another `keyframe_rope`.
     */
    public var value3:Entity;

    /**
     * The fourth constraint related entity, if any. For example, a Hydraulic constraint would return the `phys_slideconstraint` entity here. A pulley would have yet another `keyframe_...
     */
    public var value4:Entity;

}
