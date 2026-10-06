package gmod.generated.multi;

/**
 * Multiple return values from Entity.GetSequenceMovement.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class EntityMethodGetSequenceMovementResult
{
    /**
     * Whether the operation was successful
     */
    public var value1:Bool;

    /**
     * The delta vector of the animation, how much the model's origin point moved.
     */
    public var value2:Vector;

    /**
     * The delta angle of the animation.
     */
    public var value3:Angle;

}
