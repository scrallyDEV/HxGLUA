package gmod.generated.multi;

/**
 * Multiple return values from util.GetModelMeshes.
 * Automatically generated. Do not edit by hand.
 */
@:multiReturn extern class UtilLibGetModelMeshesResult
{
    /**
     * Each index in this table corresponds to a mesh within the model passed as an argument to this function. The mesh data is raw, and is not transformed via bone transformations. Th...
     */
    public var modelMeshes:gmod.NativeSequence<gmod.generated.structs.ModelMeshData>;

    /**
     * This tables indices are bone IDs for the Structures/BoneBindPose stored at each index.
     */
    public var modelBindPoses:gmod.NativeSequence<gmod.generated.structs.BoneBindPose>;

}
