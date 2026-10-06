package gmod.generated.multi;

/**
 * Multiple return values from _G.GetAddonStatus.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class GlobalLibGetAddonStatusResult
{
    /**
     * true if the game was started with -noaddons. (see Command_Line_Parameters)
     */
    public var noaddons:Bool;

    /**
     * true if the game was started with -noworkshop. (see Command_Line_Parameters)
     */
    public var noworkshop:Bool;

}
