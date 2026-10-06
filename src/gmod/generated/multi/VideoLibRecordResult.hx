package gmod.generated.multi;

/**
 * Multiple return values from video.Record.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class VideoLibRecordResult
{
    /**
     * The video object. (returns **false** if there is an error)
     */
    public var value1:IVideoWriter;

    /**
     * The error string, if there is an error.
     */
    public var value2:String;

}
