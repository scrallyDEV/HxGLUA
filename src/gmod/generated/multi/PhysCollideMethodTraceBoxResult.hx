package gmod.generated.multi;

/**
 * Multiple return values from PhysCollide.TraceBox.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PhysCollideMethodTraceBoxResult
{
    /**
     * Hit position of the trace. This is false if the trace did not hit.
     */
    public var value1:Vector;

    /**
     * Hit normal of the trace
     */
    public var value2:Vector;

    /**
     * Fraction of the trace. This is calculated from the distance between startPos, hitPos, and endPos.
     */
    public var value3:Float;

}
