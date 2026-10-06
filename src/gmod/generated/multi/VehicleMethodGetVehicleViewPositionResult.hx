package gmod.generated.multi;

/**
 * Multiple return values from Vehicle.GetVehicleViewPosition.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class VehicleMethodGetVehicleViewPositionResult
{
    /**
     * The view position, will be 0, 0, 0 on failure
     */
    public var value1:Vector;

    /**
     * The view angles, will be 0, 0, 0 on failure
     */
    public var value2:Angle;

    /**
     * The field of view, will be 0 on failure
     */
    public var value3:Float;

}
