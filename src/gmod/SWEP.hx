package gmod;

/** Active weapon definition, only available during a configured weapon main.
 * Callbacks receive their weapon instance as the explicit first argument.
 * Use SWEPStruct for the data-only structure.
 */
@:native("SWEP")
extern class SWEP
{
    public static var Base:String;
    public static var PrintName:String;
    public static var Category:String;
    public static var Spawnable:Bool;
    public static var AdminOnly:Bool;
    public static var Author:String;
    public static var ViewModel:String;
    public static var WorldModel:String;
    public static var UseHands:Bool;
    public static var Primary:Dynamic;
    public static var Secondary:Dynamic;
    public static var Initialize:(self:Weapon)->Void;
    public static var PrimaryAttack:(self:Weapon)->Void;
    public static var SecondaryAttack:(self:Weapon)->Void;
    public static var Reload:(self:Weapon)->Void;
    public static var Think:(self:Weapon)->Void;
    public static var Deploy:(self:Weapon)->Bool;
}
