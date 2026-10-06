package gmod.generated.multi;

/**
 * Multiple return values from PhysObj.GetStress.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class PhysObjMethodGetStressResult
{
    /**
     * The external stress (`𝜎𝑒`). It's the value of a giving force to other entities (in kg).
     */
    public var value1:Float;

    /**
     * The internal stress (`𝜎𝑖`). It's the value of a receiving force from other entities (in kg).
     */
    public var value2:Float;

}
