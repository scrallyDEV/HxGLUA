package shared;

import gmod.SWEP;

/** Minimal training SWEP. Uses a real scripted base and deliberately has no attacks. */
class LearningWeapon
{
    public static function main():Void
    {
        SWEP.Base = "weapon_base";
        SWEP.PrintName = "HxGMod Learning Tool";
        SWEP.Category = "HxGMod";
        SWEP.Spawnable = true;
        SWEP.UseHands = true;
        SWEP.ViewModel = "models/weapons/c_crowbar.mdl";
        SWEP.WorldModel = "models/weapons/w_crowbar.mdl";
        SWEP.Primary = untyped __lua__("{ ClipSize = -1, DefaultClip = -1, Automatic = false, Ammo = 'none' }");
        SWEP.Secondary = untyped __lua__("{ ClipSize = -1, DefaultClip = -1, Automatic = false, Ammo = 'none' }");
        SWEP.Initialize = function(self:gmod.Weapon):Void { self.setHoldType("melee"); };
        SWEP.PrimaryAttack = function(self:gmod.Weapon):Void {};
        SWEP.SecondaryAttack = function(self:gmod.Weapon):Void {};
    }
}
