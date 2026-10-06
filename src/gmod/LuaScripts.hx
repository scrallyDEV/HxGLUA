package gmod;

import gmod.GlobalLib;

/**
 * Bridge between Haxe code and ordinary Garry's Mod Lua files/modules.
 *
 * Raw Lua files placed in the project's root `lua/` directory are copied into
 * the packaged addon automatically.
 */
class LuaScripts
{
    /** Executes a raw GLua file and returns its first returned value. */
    public static inline function include(fileName:String):Dynamic
    {
        return GlobalLib.include(fileName);
    }

    /**
     * Typed convenience form of include(). The caller chooses the expected
     * return type; no runtime conversion is added.
     */
    public static inline function includeAs<T>(fileName:String):T
    {
        return cast GlobalLib.include(fileName);
    }

    /** Marks a Lua file to be sent to clients. Calling with no path sends the current file. */
    public static inline function addCSLuaFile(?fileName:String):Void
    {
        if (fileName == null)
            GlobalLib.addCSLuaFile();
        else
            GlobalLib.addCSLuaFile(fileName);
    }

    /** Loads a Garry's Mod binary or Lua module through GLua require(). */
    public static inline function require(name:String):Void
    {
        GlobalLib.require(name);
    }
}
