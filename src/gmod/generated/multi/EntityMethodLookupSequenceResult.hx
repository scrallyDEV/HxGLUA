package gmod.generated.multi;

/**
 * Multiple return values from Entity.LookupSequence.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class EntityMethodLookupSequenceResult
{
    /**
     * Sequence ID for that name. This **will** differ for models with same sequence names. Will be `-1` when the sequence is invalid or not found.
     */
    public var value1:Float;

    /**
     * The sequence duration, or `0` if the sequence is invalid or there's no sequence with given name on entity's current model.
     */
    public var value2:Float;

}
