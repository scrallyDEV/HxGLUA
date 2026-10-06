package shared;

import gmod.ENT;
import gmod.SOLID;
import gmod.MOVETYPE;

class LearningEntity
{
    public static function main():Void
    {
        ENT.Type = "anim";
        ENT.Base = "base_gmodentity";
        ENT.PrintName = "HxGMod Learning Entity";
        ENT.Category = "HxGMod";
        ENT.Spawnable = true;

        #if gmod_server
        ENT.Initialize = function(self:gmod.Entity):Void {
            self.setModel("models/props_c17/oildrum001.mdl");
            self.physicsInit(SOLID.SOLID_VPHYSICS);
            self.setMoveType(MOVETYPE.MOVETYPE_VPHYSICS);
            self.setSolid(SOLID.SOLID_VPHYSICS);
            var physics = self.getPhysicsObject();
            if (physics.isValid()) physics.wake();
        };
        #end
        #if gmod_client
        ENT.Draw = function(self:gmod.Entity):Void {
            self.drawModel();
        };
        #end
    }
}
