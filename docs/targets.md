# Create an entity or weapon

For new filesystem projects, start with [filesystem sources and migration](filesystem.md).
The bundle/HXML/configured-target instructions below describe the retained legacy
0.3.0 layout. Packaging and install safety still apply to both layouts.

Add an entity target to your project's `hxgmod.json`:

```json
"entities": {
  "my_barrel": "shared.MyBarrel"
}
```

Create `src/shared/MyBarrel.hx`:

```haxe
package shared;
import gmod.ENT;
import gmod.SOLID;
import gmod.MOVETYPE;

class MyBarrel {
    public static function main():Void {
        ENT.Type = "anim";
        ENT.Base = "base_gmodentity";
        ENT.PrintName = "My Barrel";
        ENT.Category = "My Addon";
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
        ENT.Draw = function(self:gmod.Entity):Void { self.drawModel(); };
        #end
    }
}
```

Run `hxgmod build --package`. Do not call this main from SharedMain, autorun, or an
Initialize hook. GMod creates the active `ENT` definition table when loading the
entity files. `ENT.Initialize` receives each spawned instance as its explicit
first argument; `ENT` itself is a definition, not that instance.

Targets compile separately for both realms. The package uses:

| Project | Entity output |
| --- | --- |
| Addon | `lua/entities/my_barrel/init.lua` and `cl_init.lua` |
| Gamemode | `entities/entities/my_barrel/init.lua` and `cl_init.lua` |

The server entry sends `cl_init.lua` with `AddCSLuaFile`. There is no shared Lua
bundle because shared Haxe source is included in each realm's compilation. This
uses the standard [GMod scripted entity layout](https://wiki.facepunch.com/gmod/scripted_entities).
The unfinished historical single-file Patch 13 format is not required or used.

## Weapons

Use the same pattern with `"weapons": { "weapon_example": "shared.MyWeapon" }`
and `gmod.SWEP`. Output goes under `lua/weapons/CLASS/` for addons or
`entities/weapons/CLASS/` for gamemodes. See `examples/learning/src/shared/LearningWeapon.hx`.
The example uses `weapon_base`, a crowbar model, and empty attack callbacks.
Engine weapons such as `weapon_crowbar` are not scripted bases to inherit from.
Custom attacks still need normal GMod
prediction, ammo, timing, and realm handling.

`ENT` and `SWEP` expose common typed fields and callbacks. `ENTStruct` and
`SWEPStruct` retain the generated data structures. For an uncommon field not yet
in the handwritten extern, use a deliberate raw bridge, for example
`untyped __lua__("ENT.CustomValue = {0}", 42)`, or add a typed field to the extern.
Handwritten externs survive regeneration. Do not edit generated files.

## NextBots and scripted NPCs

These are entity targets, not another compiler architecture. A NextBot uses
`ENT.Type = "nextbot"` and `ENT.Base = "base_nextbot"`. The included bot demonstrates
loading and model initialization; it does not implement navigation or behavior.
`RunBehaviour` callbacks receive `gmod.NextBot`. Scripted `ai` entities can use the
same build route; a complete AI NPC example is not supplied.

Spawn menus, inherited base behavior, physics, multiplayer transfer, prediction,
and NextBot navigation must still be checked in GMod. Offline Lua tests check the
generated code and callback convention, not the Source engine.
