package gmod.generated.multi;

/**
 * Multiple return values from Entity.GetBonePosition.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class EntityMethodGetBonePositionResult
{
    /**
     * The bone's position relative to the world. It can return nothing if the requested bone is out of bounds, or the entity has no model.
     */
    public var value1:Vector;

    /**
     * The bone's angle relative to the world.
     */
    public var value2:Angle;

}
