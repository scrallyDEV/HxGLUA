package gmod.generated.multi;

/**
 * Multiple return values from IGModAudioChannel.Get3DFadeDistance.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class IGModAudioChannelMethodGet3DFadeDistanceResult
{
    /**
     * The minimum distance. The channel's volume is at maximum when the listener is within this distance
     */
    public var value1:Float;

    /**
     * The maximum distance. The channel's volume stops decreasing when the listener is beyond this distance
     */
    public var value2:Float;

}
