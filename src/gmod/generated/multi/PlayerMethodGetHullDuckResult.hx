package gmod.generated.multi;

/**
 * Multiple return values from Player.GetHullDuck.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PlayerMethodGetHullDuckResult
{
    /**
     * The hull mins, the lowest corner of the Player's bounding box while crouching.
     */
    public var mins:Vector;

    /**
     * The hull maxs, the highest corner of the Player's crouching bounding box, opposite of the mins.
     */
    public var maxs:Vector;

}
