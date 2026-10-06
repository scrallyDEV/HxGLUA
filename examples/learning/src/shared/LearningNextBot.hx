package shared;

import gmod.ENT;

/** Stationary NextBot demonstrating that bots use the same entity build target. */
class LearningNextBot
{
    public static function main():Void
    {
        ENT.Type = "nextbot";
        ENT.Base = "base_nextbot";
        ENT.PrintName = "HxGMod Learning Bot";
        ENT.Category = "HxGMod";
        ENT.Spawnable = true;
        #if gmod_server
        ENT.Initialize = function(self:gmod.Entity):Void {
            self.setModel("models/Humans/Group01/male_07.mdl");
        };
        #end
    }
}
