package gmod.generated.multi;

/**
 * Multiple return values from coroutine.resume.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class CoroutineLibResumeResult
{
    /**
     * If the executed thread code had no errors occur within it.
     */
    public var value1:Bool;

    /**
     * If an error occurred, this will be a string containing the error message. Otherwise, this will be arguments that were yielded.
     */
    public var value2:Dynamic;

}
