package gmod;

/** Active scripted entity definition, available only while a configured entity main runs.
 * Callback assignments take the Lua self argument explicitly. Never capture ENT in a callback.
 * For the data-only structure, use ENTStruct.
 */
@:native("ENT")
extern class ENT
{
    public static var Type:String;
    public static var Base:String;
    public static var PrintName:String;
    public static var Category:String;
    public static var Spawnable:Bool;
    public static var AdminOnly:Bool;
    public static var Author:String;
    public static var Instructions:String;
    public static var AutomaticFrameAdvance:Bool;
    public static var Initialize:(self:Entity)->Void;
    public static var Think:(self:Entity)->Bool;
    public static var SetupDataTables:(self:Entity)->Void;
    public static var OnRemove:(self:Entity)->Void;
    #if (!gmod_realm_strict || gmod_client)
    public static var Draw:(self:Entity)->Void;
    #end
    #if (!gmod_realm_strict || gmod_server)
    public static var Use:(self:Entity, activator:Entity, caller:Entity, useType:Float, value:Float)->Void;
    public static var OnTakeDamage:(self:Entity, damage:CTakeDamageInfo)->Void;
    public static var RunBehaviour:(self:NextBot)->Void;
    #end
}
