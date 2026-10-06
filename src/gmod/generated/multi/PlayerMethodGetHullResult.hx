package gmod.generated.multi;

/**
 * Multiple return values from Player.GetHull.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PlayerMethodGetHullResult
{
    /**
     * The hull mins, the lowest corner of the Player's bounding box.
     */
    public var mins:Vector;

    /**
     * The hull maxs, the highest corner of the Player's bounding box, opposite of the mins.
     */
    public var maxs:Vector;

}
