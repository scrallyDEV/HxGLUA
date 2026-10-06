package gmod.generated;

/**
 * Typed helpers for standard Garry's Mod GM hooks.
 * Automatically generated. Do not edit by hand.
 */
class Hooks
{
#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a map I/O event occurs. See also [Entity:Fire](https://wiki.facepunch.com/gmod/Entity:Fire) and [Entity:Input](https://wiki.facepunch.com/gmod/Entity:Input) for func...
     * Realm: server.
     */
    public static inline function acceptInput(identifier:String, callback:(ent:Entity, input:String, activator:Entity, caller:Entity, value:Dynamic) -> Bool):Void
    {
        gmod.Hook.add("AcceptInput", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Adds a death notice entry.
     * Realm: client.
     */
    public static inline function addDeathNotice(identifier:String, callback:(attacker:String, attackerTeam:Float, inflictor:String, victim:String, victimTeam:Float) -> Dynamic):Void
    {
        gmod.Hook.add("AddDeathNotice", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to adjust the mouse sensitivity.
     * Realm: client.
     */
    public static inline function adjustMouseSensitivity(identifier:String, callback:(defaultSensitivity:Float, localFOV:Float, defaultFOV:Float) -> Float):Void
    {
        gmod.Hook.add("AdjustMouseSensitivity", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player tries to pick up something using the "use" key, return to override. This hook will not be called if `sv_playerpickupallowed` is set to 0. See [GM:GravGunPic...
     * Realm: server.
     */
    public static inline function allowPlayerPickup(identifier:String, callback:(ply:Player, ent:Entity) -> Bool):Void
    {
        gmod.Hook.add("AllowPlayerPickup", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * This hook is used to calculate animations for a player. **WARNING**: This hook must return the same values at the same time on both, client **and** server. On client for players...
     * Realm: shared.
     */
    public static inline function calcMainActivity(identifier:String, callback:(ply:Player, vel:Vector) -> Dynamic):Void
    {
        gmod.Hook.add("CalcMainActivity", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called from [GM:CalcView](https://wiki.facepunch.com/gmod/GM:CalcView) when player is in driving a vehicle. This hook may not be called in gamemodes that override [GM:CalcView](...
     * Realm: client.
     */
    public static inline function calcVehicleView(identifier:String, callback:(veh:Vehicle, ply:Player, view:Dynamic) -> Dynamic):Void
    {
        gmod.Hook.add("CalcVehicleView", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows override of the default view. 		**NOTE**: To avoid breaking compatibility with other addons, it is recommended to add onto the origin and angle values using [Vector:Add](...
     * Realm: client.
     */
    public static inline function calcView(identifier:String, callback:(ply:Player, origin:Vector, angles:Angle, fov:Float, znear:Float, zfar:Float) -> gmod.generated.structs.CamData):Void
    {
        gmod.Hook.add("CalcView", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows overriding the position and angle of the viewmodel.
     * Realm: client.
     */
    public static inline function calcViewModelView(identifier:String, callback:(wep:Weapon, vm:Entity, oldPos:Vector, oldAng:Angle, pos:Vector, ang:Angle) -> Dynamic):Void
    {
        gmod.Hook.add("CalcViewModelView", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever a players tries to create an undo.
     * Realm: server.
     */
    public static inline function canCreateUndo(identifier:String, callback:(ply:Player, undo:Dynamic) -> Bool):Void
    {
        gmod.Hook.add("CanCreateUndo", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a variable is about to be edited on an Entity (called by `Edit Properties...` menu), to determine if the edit should be permitted. See [Editable entities](https://wi...
     * Realm: server.
     */
    public static inline function canEditVariable(identifier:String, callback:(ent:Entity, ply:Player, key:String, value:String, editor:Dynamic) -> Bool):Void
    {
        gmod.Hook.add("CanEditVariable", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Determines if the player can exit the vehicle on their own. [Player:ExitVehicle](https://wiki.facepunch.com/gmod/Player:ExitVehicle) will bypass this hook. See [GM:CanPlayerEnte...
     * Realm: server.
     */
    public static inline function canExitVehicle(identifier:String, callback:(veh:Vehicle, ply:Player) -> Bool):Void
    {
        gmod.Hook.add("CanExitVehicle", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Determines whether or not a given player player can enter the given vehicle. [Player:EnterVehicle](https://wiki.facepunch.com/gmod/Player:EnterVehicle) will still call this hook...
     * Realm: server.
     */
    public static inline function canPlayerEnterVehicle(identifier:String, callback:(player:Player, vehicle:Vehicle, role:Float) -> Bool):Void
    {
        gmod.Hook.add("CanPlayerEnterVehicle", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Determines if the player can kill themselves using the `kill` or `explode` console commands.
     * Realm: server.
     */
    public static inline function canPlayerSuicide(identifier:String, callback:(player:Player) -> Bool):Void
    {
        gmod.Hook.add("CanPlayerSuicide", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Determines if the player can unfreeze the entity.
     * Realm: server.
     */
    public static inline function canPlayerUnfreeze(identifier:String, callback:(player:Player, entity:Entity, phys:PhysObj) -> Bool):Void
    {
        gmod.Hook.add("CanPlayerUnfreeze", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Controls if a [property](https://wiki.facepunch.com/gmod/properties) can be used or not.
     * Realm: shared.
     */
    public static inline function canProperty(identifier:String, callback:(ply:Player, property:String, ent:Entity) -> Bool):Void
    {
        gmod.Hook.add("CanProperty", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever a players tries to undo.
     * Realm: server.
     */
    public static inline function canUndo(identifier:String, callback:(ply:Player, undo:gmod.generated.structs.Undo) -> Bool):Void
    {
        gmod.Hook.add("CanUndo", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called each frame to record demos to video using [IVideoWriter](https://wiki.facepunch.com/gmod/IVideoWriter). **NOTE**: This hook is called every frame regardless of whether or...
     * Realm: menu.
     */
    public static inline function captureVideo(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("CaptureVideo", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a message is printed to the chat box. Note, that this isn't working with player messages even though there are arguments for it. For player messages see [GM:PlayerSa...
     * Realm: client.
     */
    public static inline function chatText(identifier:String, callback:(index:Float, name:String, text:String, type:String) -> Bool):Void
    {
        gmod.Hook.add("ChatText", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called whenever the content of the user's chat input box is changed.
     * Realm: client.
     */
    public static inline function chatTextChanged(identifier:String, callback:(text:String) -> Void):Void
    {
        gmod.Hook.add("ChatTextChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a **non local player** connects to allow the Lua system to check the password. The default behaviour in the base gamemodes emulates what would normally happen. If `s...
     * Realm: server.
     */
    public static inline function checkPassword(identifier:String, callback:(steamID64:String, ipAddress:String, svPassword:String, clPassword:String, name:String) -> Dynamic):Void
    {
        gmod.Hook.add("CheckPassword", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player's sign on state changes. You cannot get a valid player object from the userID at any point during this hook.
     * Realm: shared.
     */
    public static inline function clientSignOnStateChanged(identifier:String, callback:(userID:Float, oldState:Float, newState:Float) -> Void):Void
    {
        gmod.Hook.add("ClientSignOnStateChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client || gmod_menu)
    /**
     * Called when derma menus are closed with [Global.CloseDermaMenus](https://wiki.facepunch.com/gmod/Global.CloseDermaMenus).
     * Realm: client and menu.
     */
    public static inline function closeDermaMenus(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("CloseDermaMenus", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called whenever an entity becomes a clientside ragdoll. See [GM:CreateEntityRagdoll](https://wiki.facepunch.com/gmod/GM:CreateEntityRagdoll) for serverside ragdolls.
     * Realm: client.
     */
    public static inline function createClientsideRagdoll(identifier:String, callback:(entity:Entity, ragdoll:Entity) -> Void):Void
    {
        gmod.Hook.add("CreateClientsideRagdoll", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a serverside ragdoll of an entity has been created. See [GM:CreateClientsideRagdoll](https://wiki.facepunch.com/gmod/GM:CreateClientsideRagdoll) for clientside ragdo...
     * Realm: server.
     */
    public static inline function createEntityRagdoll(identifier:String, callback:(owner:Entity, ragdoll:Entity) -> Void):Void
    {
        gmod.Hook.add("CreateEntityRagdoll", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to change the players movements before they're sent to the server. See [Game Movement](https://wiki.facepunch.com/gmod/Game_Movement) for an explanation on the move s...
     * Realm: client.
     */
    public static inline function createMove(identifier:String, callback:(cmd:CUserCmd) -> Bool):Void
    {
        gmod.Hook.add("CreateMove", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Teams are created within this hook using [team.SetUp](https://wiki.facepunch.com/gmod/team.SetUp). This hook is called before [GM:PreGamemodeLoaded](https://wiki.facepunch.com/g...
     * Realm: shared.
     */
    public static inline function createTeams(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("CreateTeams", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called upon an animation event, this is the ideal place to call player animation functions such as [Player:AddVCDSequenceToGestureSlot](https://wiki.facepunch.com/gmod/Player:Ad...
     * Realm: shared.
     */
    public static inline function doAnimationEvent(identifier:String, callback:(ply:Player, event:Float, ?data:Float) -> Float):Void
    {
        gmod.Hook.add("DoAnimationEvent", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Handles the player's death. This hook is **not** called if the player is killed by [Player:KillSilent](https://wiki.facepunch.com/gmod/Player:KillSilent). See [GM:PlayerSilentDe...
     * Realm: server.
     */
    public static inline function doPlayerDeath(identifier:String, callback:(ply:Player, attacker:Entity, dmg:CTakeDamageInfo) -> Void):Void
    {
        gmod.Hook.add("DoPlayerDeath", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * This hook is called every frame to draw all of the current death notices.
     * Realm: client.
     */
    public static inline function drawDeathNotice(identifier:String, callback:(x:Float, y:Float) -> Void):Void
    {
        gmod.Hook.add("DrawDeathNotice", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called every frame before drawing the in-game monitors ( Breencast, in-game TVs, etc ), but doesn't seem to be doing anything, trying to render 2D or 3D elements fail.
     * Realm: client.
     */
    public static inline function drawMonitors(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("DrawMonitors", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client || gmod_menu)
    /**
     * Called after all other 2D draw hooks are called. Draws over all VGUI Panels and HUDs. Unlike [GM:HUDPaint](https://wiki.facepunch.com/gmod/GM:HUDPaint), this hook is called with...
     * Realm: client and menu.
     */
    public static inline function drawOverlay(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("DrawOverlay", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to override physgun effects rendering. **NOTE**: This is still called when `physgun_drawbeams` is set to `0`, because this hook is also capable of overriding physgun ...
     * Realm: client.
     */
    public static inline function drawPhysgunBeam(identifier:String, callback:(ply:Player, physgun:Weapon, enabled:Bool, target:Entity, physBone:Float, hitPos:Vector) -> Bool):Void
    {
        gmod.Hook.add("DrawPhysgunBeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called right before an entity stops driving. Overriding this hook will cause it to not call [drive.End](https://wiki.facepunch.com/gmod/drive.End) and the player will not stop d...
     * Realm: shared.
     */
    public static inline function endEntityDriving(identifier:String, callback:(ent:Entity, ply:Player) -> Void):Void
    {
        gmod.Hook.add("EndEntityDriving", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called whenever a sound has been played. This will not be called clientside if the server played the sound without the client also calling [Entity:EmitSound](https://wiki.facepu...
     * Realm: shared.
     */
    public static inline function entityEmitSound(identifier:String, callback:(data:Dynamic) -> Bool):Void
    {
        gmod.Hook.add("EntityEmitSound", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called every time a bullet is about to be fired from an entity, which allows to completely modify the bullet structure before the bullet is actually fired. See [GM:PostEntityFir...
     * Realm: shared.
     */
    public static inline function entityFireBullets(identifier:String, callback:(entity:Entity, data:gmod.generated.structs.Bullet) -> Bool):Void
    {
        gmod.Hook.add("EntityFireBullets", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a key-value pair is set on an entity on map spawn. Is **not** called by [Entity:SetKeyValue](https://wiki.facepunch.com/gmod/Entity:SetKeyValue). See [ENTITY:KeyValu...
     * Realm: shared.
     */
    public static inline function entityKeyValue(identifier:String, callback:(ent:Entity, key:String, value:String) -> String):Void
    {
        gmod.Hook.add("EntityKeyValue", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when an NW2Var is changed. If a NW2Var is set on an entity that is based on a Lua Entity could result in the NW2Var being mixed up with other ones and being updated multi...
     * Realm: shared.
     */
    public static inline function entityNetworkedVarChanged(identifier:String, callback:(ent:Entity, name:String, oldval:Dynamic, newval:Dynamic) -> Void):Void
    {
        gmod.Hook.add("EntityNetworkedVarChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called right before removal of an entity. 		**WARNING**: This hook is called clientside during full updates due to how networking works in the Source Engine. This can happen whe...
     * Realm: shared.
     */
    public static inline function entityRemoved(identifier:String, callback:(ent:Entity, fullUpdate:Bool) -> Void):Void
    {
        gmod.Hook.add("EntityRemoved", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when an entity is about to take damage. You can modify all parts of the damage info in this hook or completely block the damage event. See [GM:PostEntityTakeDamage](https...
     * Realm: server.
     */
    public static inline function entityTakeDamage(identifier:String, callback:(target:Entity, dmg:CTakeDamageInfo) -> Bool):Void
    {
        gmod.Hook.add("EntityTakeDamage", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * This hook polls the entity the player use action should be applied to. **NOTE**: The default behavior of this hook is in [CBasePlayer::FindUseEntity](https://github.com/ValveSof...
     * Realm: shared.
     */
    public static inline function findUseEntity(identifier:String, callback:(ply:Player, defaultEnt:Entity) -> Entity):Void
    {
        gmod.Hook.add("FindUseEntity", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Runs when user cancels/finishes typing.
     * Realm: client.
     */
    public static inline function finishChat(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("FinishChat", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called after [GM:Move](https://wiki.facepunch.com/gmod/GM:Move), applies all the changes from the [CMoveData](https://wiki.facepunch.com/gmod/CMoveData) to the player. See [Game...
     * Realm: shared.
     */
    public static inline function finishMove(identifier:String, callback:(ply:Player, mv:CMoveData) -> Bool):Void
    {
        gmod.Hook.add("FinishMove", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called to allow override of the default Derma skin for all panels. **NOTE**: This hook is only called on Lua start up, changing its value (or adding new hooks) after it has been...
     * Realm: client.
     */
    public static inline function forceDermaSkin(identifier:String, callback:() -> String):Void
    {
        gmod.Hook.add("ForceDermaSkin", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the mouse has been double clicked on any panel derived from CGModBase, such as the panel used by [gui.EnableScreenClicker](https://wiki.facepunch.com/gmod/gui.Enable...
     * Realm: client.
     */
    public static inline function gUIMouseDoublePressed(identifier:String, callback:(mouseCode:Float, aimVector:Vector) -> Void):Void
    {
        gmod.Hook.add("GUIMouseDoublePressed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called whenever a players presses a mouse key on the context menu in Sandbox or on any panel derived from CGModBase, such as the panel used by [gui.EnableScreenClicker](https://...
     * Realm: client.
     */
    public static inline function gUIMousePressed(identifier:String, callback:(mouseCode:Float, aimVector:Vector) -> Void):Void
    {
        gmod.Hook.add("GUIMousePressed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called whenever a players releases a mouse key on the context menu in Sandbox or on any panel derived from CGModBase, such as the panel used by [gui.EnableScreenClicker](https:/...
     * Realm: client.
     */
    public static inline function gUIMouseReleased(identifier:String, callback:(mouseCode:Float, aimVector:Vector) -> Void):Void
    {
        gmod.Hook.add("GUIMouseReleased", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client || gmod_menu)
    /**
     * Called when game content has been changed, for example an addon or a mountable game was (un)mounted.
     * Realm: shared and menu.
     */
    public static inline function gameContentChanged(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("GameContentChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * An internal function used to get an untranslated string to show in the kill feed as the entity's name. See [GM:SendDeathNotice](https://wiki.facepunch.com/gmod/GM:SendDeathNotice)
     * Realm: server.
     */
    public static inline function getDeathNoticeEntityName(identifier:String, callback:(name:Dynamic) -> String):Void
    {
        gmod.Hook.add("GetDeathNoticeEntityName", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player takes damage from falling, allows to override the damage.
     * Realm: server.
     */
    public static inline function getFallDamage(identifier:String, callback:(ply:Player, speed:Float) -> Float):Void
    {
        gmod.Hook.add("GetFallDamage", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when the game(server) needs to update the text shown in the server browser as the gamemode. Runs at a ~2s interval, runs even when the server is hibernating. This hook do...
     * Realm: shared.
     */
    public static inline function getGameDescription(identifier:String, callback:() -> String):Void
    {
        gmod.Hook.add("GetGameDescription", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to modify the Source Engine's motion blur shaders.
     * Realm: client.
     */
    public static inline function getMotionBlurValues(identifier:String, callback:(horizontal:Float, vertical:Float, forward:Float, rotational:Float) -> Dynamic):Void
    {
        gmod.Hook.add("GetMotionBlurValues", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called to determine preferred carry angles for the entity. It works for both, +use pickup and gravity gun pickup. **WARNING**: Due to nature of the gravity gun coding in multipl...
     * Realm: server.
     */
    public static inline function getPreferredCarryAngles(identifier:String, callback:(ent:Entity, ply:Player) -> Angle):Void
    {
        gmod.Hook.add("GetPreferredCarryAngles", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Returns the color for the given entity's team. This is used in chat and deathnotice text.
     * Realm: client.
     */
    public static inline function getTeamColor(identifier:String, callback:(ent:Entity) -> Color):Void
    {
        gmod.Hook.add("GetTeamColor", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Returns the team color for the given team index.
     * Realm: client.
     */
    public static inline function getTeamNumColor(identifier:String, callback:(team:Float) -> Color):Void
    {
        gmod.Hook.add("GetTeamNumColor", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Override this hook to disable/change ear-grabbing in your gamemode. By default, it is not called anywhere on the server.
     * Realm: shared.
     */
    public static inline function grabEarAnimation(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("GrabEarAnimation", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when an entity is released by a gravity gun. See [GM:PhysgunDrop](https://wiki.facepunch.com/gmod/GM:PhysgunDrop) for the Physics Gun drop variant.
     * Realm: server.
     */
    public static inline function gravGunOnDropped(identifier:String, callback:(ply:Player, ent:Entity) -> Void):Void
    {
        gmod.Hook.add("GravGunOnDropped", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when an entity is picked up by a gravity gun. See [GM:OnPlayerPhysicsPickup](https://wiki.facepunch.com/gmod/GM:OnPlayerPhysicsPickup) for the player `+use` pickup varian...
     * Realm: server.
     */
    public static inline function gravGunOnPickedUp(identifier:String, callback:(ply:Player, ent:Entity) -> Void):Void
    {
        gmod.Hook.add("GravGunOnPickedUp", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called every tick to poll whether a player is allowed to pick up an entity with the gravity gun or not. See [GM:AllowPlayerPickup](https://wiki.facepunch.com/gmod/GM:AllowPlayer...
     * Realm: server.
     */
    public static inline function gravGunPickupAllowed(identifier:String, callback:(ply:Player, ent:Entity) -> Bool):Void
    {
        gmod.Hook.add("GravGunPickupAllowed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when an entity is about to be punted with the gravity gun (primary fire). By default this function makes [ENTITY:GravGunPunt](https://wiki.facepunch.com/gmod/ENTITY:GravG...
     * Realm: shared.
     */
    public static inline function gravGunPunt(identifier:String, callback:(ply:Player, ent:Entity) -> Bool):Void
    {
        gmod.Hook.add("GravGunPunt", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the client has picked up ammo. Override to disable default HUD notification.
     * Realm: client.
     */
    public static inline function hUDAmmoPickedUp(identifier:String, callback:(itemName:String, amount:Float) -> Void):Void
    {
        gmod.Hook.add("HUDAmmoPickedUp", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Renders the HUD pick-up history. Override to hide default or draw your own HUD.
     * Realm: client.
     */
    public static inline function hUDDrawPickupHistory(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("HUDDrawPickupHistory", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called every frame to render the scoreboard. It is recommended to use Derma and VGUI for this job instead of this hook. Called right after [GM:HUDPaint](https://wiki.facepunch.c...
     * Realm: client.
     */
    public static inline function hUDDrawScoreBoard(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("HUDDrawScoreBoard", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called from [GM:HUDPaint](https://wiki.facepunch.com/gmod/GM:HUDPaint) to draw player info when you hover over a player with your crosshair or mouse.
     * Realm: client.
     */
    public static inline function hUDDrawTargetID(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("HUDDrawTargetID", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when an item has been picked up. Override to disable the default HUD notification.
     * Realm: client.
     */
    public static inline function hUDItemPickedUp(identifier:String, callback:(itemName:String) -> Void):Void
    {
        gmod.Hook.add("HUDItemPickedUp", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called whenever the HUD should be drawn. 		This is the ideal place to draw custom HUD elements. 		To prevent the default game HUD from drawing, use [GM:HUDShouldDraw](https://wi...
     * Realm: client.
     */
    public static inline function hUDPaint(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("HUDPaint", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before [GM:HUDPaint](https://wiki.facepunch.com/gmod/GM:HUDPaint) when the HUD background is being drawn. Just like [GM:HUDPaint](https://wiki.facepunch.com/gmod/GM:HUDPa...
     * Realm: client.
     */
    public static inline function hUDPaintBackground(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("HUDPaintBackground", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the Gamemode is about to draw a given element on the client's HUD (heads-up display). **WARNING**: This hook is called HUNDREDS of times per second (more than 5 time...
     * Realm: client.
     */
    public static inline function hUDShouldDraw(identifier:String, callback:(name:String) -> Bool):Void
    {
        gmod.Hook.add("HUDShouldDraw", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a weapon has been picked up. Override to disable the default HUD notification.
     * Realm: client.
     */
    public static inline function hUDWeaponPickedUp(identifier:String, callback:(weapon:Weapon) -> Void):Void
    {
        gmod.Hook.add("HUDWeaponPickedUp", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called to handle player armor reduction, when player receives damage. Clarify hook order with other damage hooks.
     * Realm: server.
     */
    public static inline function handlePlayerArmorReduction(identifier:String, callback:(ply:Player, dmginfo:CTakeDamageInfo) -> Void):Void
    {
        gmod.Hook.add("HandlePlayerArmorReduction", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Allows to override player driving animations.
     * Realm: shared.
     */
    public static inline function handlePlayerDriving(identifier:String, callback:(ply:Player) -> Bool):Void
    {
        gmod.Hook.add("HandlePlayerDriving", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Allows to override player crouch animations.
     * Realm: shared.
     */
    public static inline function handlePlayerDucking(identifier:String, callback:(ply:Player, velocity:Vector) -> Bool):Void
    {
        gmod.Hook.add("HandlePlayerDucking", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called every frame by the player model animation system. Allows to override player jumping animations.
     * Realm: shared.
     */
    public static inline function handlePlayerJumping(identifier:String, callback:(ply:Player, velocity:Vector) -> Bool):Void
    {
        gmod.Hook.add("HandlePlayerJumping", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called every frame by the player model animation system. Allows to override player landing animations.
     * Realm: shared.
     */
    public static inline function handlePlayerLanding(identifier:String, callback:(ply:Player, velocity:Vector, onGround:Bool) -> Bool):Void
    {
        gmod.Hook.add("HandlePlayerLanding", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Allows to override player noclip animations.
     * Realm: shared.
     */
    public static inline function handlePlayerNoClipping(identifier:String, callback:(ply:Player, velocity:Vector) -> Bool):Void
    {
        gmod.Hook.add("HandlePlayerNoClipping", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Allows to override player swimming animations.
     * Realm: shared.
     */
    public static inline function handlePlayerSwimming(identifier:String, callback:(ply:Player, velocity:Vector) -> Bool):Void
    {
        gmod.Hook.add("HandlePlayerSwimming", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Allows to override player flying ( in mid-air, not noclipping ) animations.
     * Realm: shared.
     */
    public static inline function handlePlayerVaulting(identifier:String, callback:(ply:Player, velocity:Vector) -> Bool):Void
    {
        gmod.Hook.add("HandlePlayerVaulting", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Hides the team selection panel.
     * Realm: client.
     */
    public static inline function hideTeam(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("HideTeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called after all the entities are initialized. Starting from this hook [Global.LocalPlayer](https://wiki.facepunch.com/gmod/Global.LocalPlayer) will return valid object. **NOTE*...
     * Realm: shared.
     */
    public static inline function initPostEntity(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("InitPostEntity", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called after the gamemode loads and starts. No entities would be present at the time this hook is called, please see [GM:InitPostEntity](https://wiki.facepunch.com/gmod/GM:InitP...
     * Realm: shared.
     */
    public static inline function initialize(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("Initialize", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to modify the supplied User Command with mouse input. This could be used to make moving the mouse do funky things to view angles.
     * Realm: client.
     */
    public static inline function inputMouseApply(identifier:String, callback:(cmd:CUserCmd, x:Float, y:Float, ang:Angle) -> Bool):Void
    {
        gmod.Hook.add("InputMouseApply", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Check if a player can spawn at a certain spawnpoint.
     * Realm: server.
     */
    public static inline function isSpawnpointSuitable(identifier:String, callback:(ply:Player, spawnpoint:Entity, makeSuitable:Bool) -> Bool):Void
    {
        gmod.Hook.add("IsSpawnpointSuitable", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called whenever a player pressed a key included within the IN keys. For a more general purpose function that handles all kinds of input, see [GM:PlayerButtonDown](https://wiki.f...
     * Realm: shared.
     */
    public static inline function keyPress(identifier:String, callback:(ply:Player, key:Float) -> Void):Void
    {
        gmod.Hook.add("KeyPress", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Runs when a IN key was released by a player. For a more general purpose function that handles all kinds of input, see [GM:PlayerButtonUp](https://wiki.facepunch.com/gmod/GM:Play...
     * Realm: shared.
     */
    public static inline function keyRelease(identifier:String, callback:(ply:Player, key:Float) -> Void):Void
    {
        gmod.Hook.add("KeyRelease", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * **INTERNAL**: This is used internally - although you're able to use it you probably shouldn't. Called from `gm_load` when the game should load a map.
     * Realm: server.
     */
    public static inline function loadGModSave(identifier:String, callback:(data:String, map:String, timestamp:Float) -> Void):Void
    {
        gmod.Hook.add("LoadGModSave", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called while an addon from the Steam workshop is downloading. Used by default to update details on the fancy workshop download panel.
     * Realm: menu.
     */
    public static inline function loadGModSaveFailed(identifier:String, callback:(reason:String, workshopid:String) -> Void):Void
    {
        gmod.Hook.add("LoadGModSaveFailed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when `menu.lua` has finished loading.
     * Realm: menu.
     */
    public static inline function menuStart(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("MenuStart", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Override this gamemode function to disable mouth movement when talking on voice chat. By default, it is not called anywhere on the server.
     * Realm: shared.
     */
    public static inline function mouthMoveAnimation(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("MouthMoveAnimation", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * The Move hook is called for you to manipulate the player's MoveData. You shouldn't adjust the player's position in any way in the move hook. This is because due to prediction er...
     * Realm: shared.
     */
    public static inline function move(identifier:String, callback:(ply:Player, mv:CMoveData) -> Bool):Void
    {
        gmod.Hook.add("Move", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Returning true in this hook will cause it to render depth buffers defined with [render.GetResolvedFullFrameDepth](https://wiki.facepunch.com/gmod/render.GetResolvedFullFrameDepth).
     * Realm: client.
     */
    public static inline function needsDepthPass(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("NeedsDepthPass", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when an entity has been created over the network.
     * Realm: client.
     */
    public static inline function networkEntityCreated(identifier:String, callback:(ent:Entity) -> Void):Void
    {
        gmod.Hook.add("NetworkEntityCreated", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player's SteamID has been validated by Steam. See also [GM:PlayerAuthed](https://wiki.facepunch.com/gmod/GM:PlayerAuthed) and [Player:IsFullyAuthenticated](https:/...
     * Realm: server.
     */
    public static inline function networkIDValidated(identifier:String, callback:(name:String, steamID:String, ownerID:String) -> Void):Void
    {
        gmod.Hook.add("NetworkIDValidated", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called whenever this entity changes its transmission state for this [Global.LocalPlayer](https://wiki.facepunch.com/gmod/Global.LocalPlayer), such as exiting or re entering the ...
     * Realm: client.
     */
    public static inline function notifyShouldTransmit(identifier:String, callback:(entity:Entity, shouldtransmit:Bool) -> Void):Void
    {
        gmod.Hook.add("NotifyShouldTransmit", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a player has achieved an achievement. You can get the name and other information from an achievement ID with the [achievements](https://wiki.facepunch.com/gmod/achie...
     * Realm: client.
     */
    public static inline function onAchievementAchieved(identifier:String, callback:(ply:Player, achievement:Float) -> Void):Void
    {
        gmod.Hook.add("OnAchievementAchieved", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the local player presses TAB while having their chatbox opened. 	 		**WARNING**: This function now uses [player.Iterator](https://wiki.facepunch.com/gmod/player.Iter...
     * Realm: client.
     */
    public static inline function onChatTab(identifier:String, callback:(text:String) -> String):Void
    {
        gmod.Hook.add("OnChatTab", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the player cleans up something.
     * Realm: client.
     */
    public static inline function onCleanup(identifier:String, callback:(name:String) -> Bool):Void
    {
        gmod.Hook.add("OnCleanup", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called on the server when a Lua error occurs on a client and is sent to the server. This hook allows server-side code to detect and log client-side errors. See [GM:OnLuaError](h...
     * Realm: server.
     */
    public static inline function onClientLuaError(identifier:String, callback:(error:String, ply:Player, stack:Dynamic, name:String) -> Void):Void
    {
        gmod.Hook.add("OnClientLuaError", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a caption/subtitle has been emitted to the closed caption box.
     * Realm: client.
     */
    public static inline function onCloseCaptionEmit(identifier:String, callback:(soundScript:String, duration:Float, fromPlayer:Bool, fullText:String) -> Bool):Void
    {
        gmod.Hook.add("OnCloseCaptionEmit", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the context menu keybind (+menu_context) is released, which by default is C. This hook will not run if [input.IsKeyTrapping](https://wiki.facepunch.com/gmod/input.Is...
     * Realm: client.
     */
    public static inline function onContextMenuClose(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnContextMenuClose", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the context menu keybind (`+menu_context`) is pressed, which by default is C. See also [GM:OnContextMenuClose](https://wiki.facepunch.com/gmod/GM:OnContextMenuClose).
     * Realm: client.
     */
    public static inline function onContextMenuOpen(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnContextMenuOpen", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when the crazy physics detection detects an entity with crazy physics, i.e. position being far outside of the map, velocities being near or at infinity, etc. The primary ...
     * Realm: shared.
     */
    public static inline function onCrazyPhysics(identifier:String, callback:(ent:Entity, physobj:PhysObj) -> Void):Void
    {
        gmod.Hook.add("OnCrazyPhysics", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player has been hurt by an explosion. Override to disable default sound effect.
     * Realm: server.
     */
    public static inline function onDamagedByExplosion(identifier:String, callback:(ply:Player, dmginfo:CTakeDamageInfo) -> Void):Void
    {
        gmod.Hook.add("OnDamagedByExplosion", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called as soon as the entity is created. Very little of the entity's properties will be initialized at this stage. (keyvalues, classname, flags, anything), especially on the ser...
     * Realm: shared.
     */
    public static inline function onEntityCreated(identifier:String, callback:(entity:Entity) -> Void):Void
    {
        gmod.Hook.add("OnEntityCreated", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when the [Entity:WaterLevel](https://wiki.facepunch.com/gmod/Entity:WaterLevel) of an entity is changed. 0 - The entity isn't in water. 1 - Slightly submerged (at least t...
     * Realm: server.
     */
    public static inline function onEntityWaterLevelChanged(identifier:String, callback:(entity:Entity, old:Float, new_:Float) -> Void):Void
    {
        gmod.Hook.add("OnEntityWaterLevelChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when the gamemode is loaded. [gmod.GetGamemode](https://wiki.facepunch.com/gmod/gmod.GetGamemode) will be functional at this point. [Global.LocalPlayer](https://wiki.face...
     * Realm: shared.
     */
    public static inline function onGamemodeLoaded(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnGamemodeLoaded", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client || gmod_menu)
    /**
     * Called when a Lua error occurs. If you want to retrieve client errors on the server side, you can use this hook: [GM:OnClientLuaError](https://wiki.facepunch.com/gmod/GM:OnClien...
     * Realm: shared and menu.
     */
    public static inline function onLuaError(identifier:String, callback:(error:String, realm:String, stack:Dynamic, name:String, id:String) -> Void):Void
    {
        gmod.Hook.add("OnLuaError", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever an NPC drops an item upon its death, such as health kits, armor batteries, etc. It will NOT be called for dropped weapons, with exception of Half-Life: Source NP...
     * Realm: server.
     */
    public static inline function onNPCDropItem(identifier:String, callback:(npc:NPC, item:Entity) -> Void):Void
    {
        gmod.Hook.add("OnNPCDropItem", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever an NPC is killed.
     * Realm: server.
     */
    public static inline function onNPCKilled(identifier:String, callback:(npc:NPC, attacker:Entity, inflictor:Entity) -> Void):Void
    {
        gmod.Hook.add("OnNPCKilled", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when a Addon Conflict occurs, only works in the Menu realm.
     * Realm: menu.
     */
    public static inline function onNotifyAddonConflict(identifier:String, callback:(addon1:String, addon2:String, fileName:String) -> Void):Void
    {
        gmod.Hook.add("OnNotifyAddonConflict", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when the main menu has been blocked by [GM:OnPauseMenuShow](https://wiki.facepunch.com/gmod/GM:OnPauseMenuShow) four times in a small interval. This is used internally to...
     * Realm: menu.
     */
    public static inline function onPauseMenuBlockedTooManyTimes(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnPauseMenuBlockedTooManyTimes", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the pause menu is attempting to be opened. Allows you to prevent the main menu from being opened that time. 	The user can hold SHIFT to not call this hook. If the ma...
     * Realm: client.
     */
    public static inline function onPauseMenuShow(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("OnPauseMenuShow", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when a permission gets Granted or Revoked.
     * Realm: menu.
     */
    public static inline function onPermissionsChanged(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnPermissionsChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player freezes an entity with the physgun.
     * Realm: server.
     */
    public static inline function onPhysgunFreeze(identifier:String, callback:(weapon:Entity, physobj:PhysObj, ent:Entity, ply:Player) -> Bool):Void
    {
        gmod.Hook.add("OnPhysgunFreeze", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called to when a player has successfully picked up an entity with their Physics Gun. Not to be confused with [GM:PhysgunPickup](https://wiki.facepunch.com/gmod/GM:PhysgunPickup)...
     * Realm: server.
     */
    public static inline function onPhysgunPickup(identifier:String, callback:(ply:Player, ent:Entity) -> Void):Void
    {
        gmod.Hook.add("OnPhysgunPickup", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player reloads with the physgun. Override this to disable default unfreezing behavior. 		 			Regardless of whether or not you return true or false, it will disable...
     * Realm: server.
     */
    public static inline function onPhysgunReload(identifier:String, callback:(physgun:Weapon, ply:Player) -> Bool):Void
    {
        gmod.Hook.add("OnPhysgunReload", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player has changed team using [GM:PlayerJoinTeam](https://wiki.facepunch.com/gmod/GM:PlayerJoinTeam). **WARNING**: This hook will not work with [hook.Add](https://...
     * Realm: server.
     */
    public static inline function onPlayerChangedTeam(identifier:String, callback:(ply:Player, oldTeam:Float, newTeam:Float) -> Void):Void
    {
        gmod.Hook.add("OnPlayerChangedTeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called whenever a player sends a chat message. For the serverside equivalent, see [GM:PlayerSay](https://wiki.facepunch.com/gmod/GM:PlayerSay). **NOTE**: The input (or suppressi...
     * Realm: client.
     */
    public static inline function onPlayerChat(identifier:String, callback:(ply:Player, text:String, teamChat:Bool, isDead:Bool) -> Bool):Void
    {
        gmod.Hook.add("OnPlayerChat", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player makes contact with the ground after a jump or a fall.
     * Realm: shared.
     */
    public static inline function onPlayerHitGround(identifier:String, callback:(player:Entity, inWater:Bool, onFloater:Bool, speed:Float) -> Bool):Void
    {
        gmod.Hook.add("OnPlayerHitGround", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player jumps.
     * Realm: shared.
     */
    public static inline function onPlayerJump(identifier:String, callback:(player:Entity, speed:Float) -> Void):Void
    {
        gmod.Hook.add("OnPlayerJump", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player +use drops an entity.
     * Realm: server.
     */
    public static inline function onPlayerPhysicsDrop(identifier:String, callback:(ply:Player, ent:Entity, thrown:Bool) -> Void):Void
    {
        gmod.Hook.add("OnPlayerPhysicsDrop", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player +use pickups up an entity. This will be called after the entity passes though [GM:AllowPlayerPickup](https://wiki.facepunch.com/gmod/GM:AllowPlayerPickup). ...
     * Realm: server.
     */
    public static inline function onPlayerPhysicsPickup(identifier:String, callback:(ply:Player, ent:Entity) -> Void):Void
    {
        gmod.Hook.add("OnPlayerPhysicsPickup", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when gamemode has been reloaded by auto refresh. **NOTE**: It seems that this event can be triggered more than once for a single refresh event.
     * Realm: shared.
     */
    public static inline function onReloaded(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnReloaded", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the player's screen resolution of the game changes. This also called when changing MSAA settings. [Global.ScrW](https://wiki.facepunch.com/gmod/Global.ScrW) and [Glo...
     * Realm: client.
     */
    public static inline function onScreenSizeChanged(identifier:String, callback:(oldWidth:Float, oldHeight:Float, newWidth:Float, newHeight:Float) -> Void):Void
    {
        gmod.Hook.add("OnScreenSizeChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a player releases the `+menu` bind on their keyboard, which is bound to Q by default.
     * Realm: client.
     */
    public static inline function onSpawnMenuClose(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnSpawnMenuClose", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a player presses the `+menu` bind on their keyboard, which is bound to Q by default.
     * Realm: client.
     */
    public static inline function onSpawnMenuOpen(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("OnSpawnMenuOpen", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a [DTextEntry](https://wiki.facepunch.com/gmod/DTextEntry) gets focus. This hook is run from [DTextEntry:OnGetFocus](https://wiki.facepunch.com/gmod/DTextEntry:OnGet...
     * Realm: client.
     */
    public static inline function onTextEntryGetFocus(identifier:String, callback:(panel:Panel) -> Void):Void
    {
        gmod.Hook.add("OnTextEntryGetFocus", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a [DTextEntry](https://wiki.facepunch.com/gmod/DTextEntry) loses focus.
     * Realm: client.
     */
    public static inline function onTextEntryLoseFocus(identifier:String, callback:(panel:Panel) -> Void):Void
    {
        gmod.Hook.add("OnTextEntryLoseFocus", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the player undoes something.
     * Realm: client.
     */
    public static inline function onUndo(identifier:String, callback:(name:String, customText:String) -> Bool):Void
    {
        gmod.Hook.add("OnUndo", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when the player changes their weapon to another one - and their viewmodel model changes. This is not always called clientside.
     * Realm: shared.
     */
    public static inline function onViewModelChanged(identifier:String, callback:(viewmodel:Entity, oldModel:String, newModel:String) -> Void):Void
    {
        gmod.Hook.add("OnViewModelChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player drops an entity with the Physgun. See [GM:GravGunOnDropped](https://wiki.facepunch.com/gmod/GM:GravGunOnDropped) for the Gravity Gun drop variant.
     * Realm: shared.
     */
    public static inline function physgunDrop(identifier:String, callback:(player:Player, entity:Entity) -> Void):Void
    {
        gmod.Hook.add("PhysgunDrop", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called to determine if a player should be able to pick up an entity with the Physics Gun. See [GM:OnPhysgunPickup](https://wiki.facepunch.com/gmod/GM:OnPhysgunPickup) for a hook...
     * Realm: shared.
     */
    public static inline function physgunPickup(identifier:String, callback:(player:Player, entity:Entity) -> Bool):Void
    {
        gmod.Hook.add("PhysgunPickup", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called after player's reserve ammo count changes.
     * Realm: shared.
     */
    public static inline function playerAmmoChanged(identifier:String, callback:(ply:Player, ammoID:Float, oldCount:Float, newCount:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerAmmoChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called after the player gets their [Player:UniqueID](https://wiki.facepunch.com/gmod/Player:UniqueID) set for the first time. This hook will also be called in singleplayer. See ...
     * Realm: server.
     */
    public static inline function playerAuthed(identifier:String, callback:(ply:Player, steamid:String, uniqueid:String) -> Void):Void
    {
        gmod.Hook.add("PlayerAuthed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Runs when a bind has been pressed. Allows to block commands. **NOTE**: By using the "alias" console command, this hook can be effectively circumvented. To prevent this use [inpu...
     * Realm: client.
     */
    public static inline function playerBindPress(identifier:String, callback:(ply:Player, bind:String, pressed:Bool, code:Float) -> Bool):Void
    {
        gmod.Hook.add("PlayerBindPress", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player presses a button. This will not be called if player has a panel opened with keyboard input enabled, use [PANEL:OnKeyCodePressed](https://wiki.facepunch.com/...
     * Realm: shared.
     */
    public static inline function playerButtonDown(identifier:String, callback:(ply:Player, button:gmod.generated.enums.BUTTON_CODE) -> Void):Void
    {
        gmod.Hook.add("PlayerButtonDown", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player releases a button. This will not be called if player has a panel opened with keyboard input enabled, use [PANEL:OnKeyCodeReleased](https://wiki.facepunch.co...
     * Realm: shared.
     */
    public static inline function playerButtonUp(identifier:String, callback:(ply:Player, button:gmod.generated.enums.BUTTON_CODE) -> Void):Void
    {
        gmod.Hook.add("PlayerButtonUp", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Decides whether a player can hear another player using voice chat. **WARNING**: This hook is called **players count * speaking players count** times every 0.3 seconds if at leas...
     * Realm: server.
     */
    public static inline function playerCanHearPlayersVoice(identifier:String, callback:(listener:Player, talker:Player) -> Dynamic):Void
    {
        gmod.Hook.add("PlayerCanHearPlayersVoice", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Returns whether or not a player is allowed to join a team 		**WARNING**: This hook will not work with [hook.Add](https://wiki.facepunch.com/gmod/hook.Add) and it is only called ...
     * Realm: server.
     */
    public static inline function playerCanJoinTeam(identifier:String, callback:(ply:Player, team:Float) -> Bool):Void
    {
        gmod.Hook.add("PlayerCanJoinTeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Returns whether or not a player is allowed to pick an item up. (ammo, health, armor) This will typically only work for base game entities, unless mod authors that implement simi...
     * Realm: server.
     */
    public static inline function playerCanPickupItem(identifier:String, callback:(ply:Player, item:Entity) -> Bool):Void
    {
        gmod.Hook.add("PlayerCanPickupItem", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Returns whether or not a player is allowed to pick up a weapon. 	If this returns `false`, [Player:Give](https://wiki.facepunch.com/gmod/Player:Give) won't work. See [GM:PlayerCa...
     * Realm: server.
     */
    public static inline function playerCanPickupWeapon(identifier:String, callback:(ply:Player, weapon:Weapon) -> Bool):Void
    {
        gmod.Hook.add("PlayerCanPickupWeapon", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Returns whether or not the player can see the other player's chat. **NOTE**: The **speaker** parameter does not have to be a valid [Player](https://wiki.facepunch.com/gmod/Playe...
     * Realm: server.
     */
    public static inline function playerCanSeePlayersChat(identifier:String, callback:(text:String, teamOnly:Bool, listener:Player, speaker:Player) -> Bool):Void
    {
        gmod.Hook.add("PlayerCanSeePlayersChat", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player has changed team using [Player:SetTeam](https://wiki.facepunch.com/gmod/Player:SetTeam). 	**WARNING**: Avoid calling [Player:SetTeam](https://wiki.facepunch...
     * Realm: server.
     */
    public static inline function playerChangedTeam(identifier:String, callback:(ply:Player, oldTeam:Float, newTeam:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerChangedTeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called whenever a player is about to spawn something to see if they hit a limit for whatever they are spawning. 	**NOTE**: This hook will not be called in singleplayer, as singl...
     * Realm: shared.
     */
    public static inline function playerCheckLimit(identifier:String, callback:(ply:Player, limitName:String, current:Float, defaultMax:Float) -> Bool):Void
    {
        gmod.Hook.add("PlayerCheckLimit", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * **INTERNAL**: This is used internally - although you're able to use it you probably shouldn't. Called whenever a player's class is changed on the server-side with [player_manage...
     * Realm: client.
     */
    public static inline function playerClassChanged(identifier:String, callback:(ply:Player, newID:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerClassChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Executes when a player connects to the server. Called before the player has been assigned a [UserID](https://wiki.facepunch.com/gmod/Player:UserID) and entity. See the [player_c...
     * Realm: shared.
     */
    public static inline function playerConnect(identifier:String, callback:(name:String, ip:String) -> Void):Void
    {
        gmod.Hook.add("PlayerConnect", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player is killed by [Player:Kill](https://wiki.facepunch.com/gmod/Player:Kill) or any other normal means. This hook is **not** called if the player is killed by [P...
     * Realm: server.
     */
    public static inline function playerDeath(identifier:String, callback:(victim:Player, inflictor:Entity, attacker:Entity) -> Void):Void
    {
        gmod.Hook.add("PlayerDeath", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Returns whether or not the default death sound should be muted.
     * Realm: server.
     */
    public static inline function playerDeathSound(identifier:String, callback:(ply:Player) -> Bool):Void
    {
        gmod.Hook.add("PlayerDeathSound", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called every think while the player is dead. The return value will determine if the player respawns. Overwriting this function will prevent players from respawning by pressing s...
     * Realm: server.
     */
    public static inline function playerDeathThink(identifier:String, callback:(ply:Player) -> Bool):Void
    {
        gmod.Hook.add("PlayerDeathThink", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player leaves the server. See the [player_disconnect gameevent](https://wiki.facepunch.com/gmod/gameevent/player_disconnect) for a shared version of this hook that...
     * Realm: server.
     */
    public static inline function playerDisconnected(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PlayerDisconnected", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called to update the player's animation during a drive.
     * Realm: shared.
     */
    public static inline function playerDriveAnimate(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PlayerDriveAnimate", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a weapon is dropped by a player via [Player:DropWeapon](https://wiki.facepunch.com/gmod/Player:DropWeapon). Despite its name, this hook is also called for NPC weapon...
     * Realm: server.
     */
    public static inline function playerDroppedWeapon(identifier:String, callback:(owner:Dynamic, wep:Weapon) -> Void):Void
    {
        gmod.Hook.add("PlayerDroppedWeapon", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when player stops using voice chat. See [GM:PlayerStartVoice](https://wiki.facepunch.com/gmod/GM:PlayerStartVoice) for the opposite hook.
     * Realm: client.
     */
    public static inline function playerEndVoice(identifier:String, callback:(ply:Player, plyIndex:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerEndVoice", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player enters a vehicle. Called just after [GM:CanPlayerEnterVehicle](https://wiki.facepunch.com/gmod/GM:CanPlayerEnterVehicle). See also [GM:PlayerLeaveVehicle](h...
     * Realm: server.
     */
    public static inline function playerEnteredVehicle(identifier:String, callback:(ply:Player, veh:Vehicle, role:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerEnteredVehicle", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before firing clientside animation events on a player model. See [GM:PlayerHandleAnimEvent](https://wiki.facepunch.com/gmod/GM:PlayerHandleAnimEvent) for the serverside v...
     * Realm: client.
     */
    public static inline function playerFireAnimationEvent(identifier:String, callback:(ply:Player, pos:Vector, ang:Angle, event:Float, name:String) -> Bool):Void
    {
        gmod.Hook.add("PlayerFireAnimationEvent", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called whenever a player steps. Return true to mute the normal sound. See [GM:PlayerStepSoundTime](https://wiki.facepunch.com/gmod/GM:PlayerStepSoundTime) for a related hook abo...
     * Realm: shared.
     */
    public static inline function playerFootstep(identifier:String, callback:(ply:Player, pos:Vector, foot:Float, sound:String, volume:Float, filter:CRecipientFilter) -> Bool):Void
    {
        gmod.Hook.add("PlayerFootstep", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player freezes an object.
     * Realm: server.
     */
    public static inline function playerFrozeObject(identifier:String, callback:(ply:Player, ent:Entity, physobj:PhysObj) -> Void):Void
    {
        gmod.Hook.add("PlayerFrozeObject", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called before firing serverside animation events on the player models. See [GM:PlayerFireAnimationEvent](https://wiki.facepunch.com/gmod/GM:PlayerFireAnimationEvent) for the cli...
     * Realm: server.
     */
    public static inline function playerHandleAnimEvent(identifier:String, callback:(ply:Player, event:Float, eventTime:Float, cycle:Float, type:Float, options:String) -> Void):Void
    {
        gmod.Hook.add("PlayerHandleAnimEvent", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player gets hurt.
     * Realm: server.
     */
    public static inline function playerHurt(identifier:String, callback:(victim:Player, attacker:Entity, healthRemaining:Float, damageTaken:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerHurt", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when the player spawns for the first time. See [GM:PlayerSpawn](https://wiki.facepunch.com/gmod/GM:PlayerSpawn) for a hook called every player spawn. **NOTE**: This hook ...
     * Realm: server.
     */
    public static inline function playerInitialSpawn(identifier:String, callback:(player:Player, transition:Bool) -> Void):Void
    {
        gmod.Hook.add("PlayerInitialSpawn", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Makes the player join a specified team. This is a convenience function that calls [Player:SetTeam](https://wiki.facepunch.com/gmod/Player:SetTeam) and runs the [GM:OnPlayerChang...
     * Realm: server.
     */
    public static inline function playerJoinTeam(identifier:String, callback:(ply:Player, team:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerJoinTeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player leaves a vehicle for any reason, including [Player:ExitVehicle](https://wiki.facepunch.com/gmod/Player:ExitVehicle). See [GM:PlayerEnteredVehicle](https://w...
     * Realm: server.
     */
    public static inline function playerLeaveVehicle(identifier:String, callback:(ply:Player, veh:Vehicle) -> Void):Void
    {
        gmod.Hook.add("PlayerLeaveVehicle", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called to give players the default set of weapons. **NOTE**: This function may not work in your custom gamemode if you have overridden your [GM:PlayerSpawn](https://wiki.facepun...
     * Realm: server.
     */
    public static inline function playerLoadout(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PlayerLoadout", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player tries to switch noclip mode. [MOVETYPE_NOCLIP](https://wiki.facepunch.com/gmod/Enums/MOVETYPE#MOVETYPE_NOCLIP) can be used to determine if a player is curre...
     * Realm: shared.
     */
    public static inline function playerNoClip(identifier:String, callback:(ply:Player, desiredState:Bool) -> Bool):Void
    {
        gmod.Hook.add("PlayerNoClip", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called after the player's think, just after [GM:FinishMove](https://wiki.facepunch.com/gmod/GM:FinishMove). 		**NOTE**: On the client side, it is only called for the local player.
     * Realm: shared.
     */
    public static inline function playerPostThink(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PlayerPostThink", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Request a player to join the team. This function will check if the team is available to join or not. This hook is called when the player runs "changeteam" in the console. To pre...
     * Realm: server.
     */
    public static inline function playerRequestTeam(identifier:String, callback:(ply:Player, team:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerRequestTeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player dispatched a chat message. For the clientside equivalent, see [GM:OnPlayerChat](https://wiki.facepunch.com/gmod/GM:OnPlayerChat). 		**NOTE**: It may be more...
     * Realm: server.
     */
    public static inline function playerSay(identifier:String, callback:(sender:Player, text:String, teamChat:Bool) -> String):Void
    {
        gmod.Hook.add("PlayerSay", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called to determine a spawn point for a player to spawn at. 		**NOTE**: The spawn point entity will also impact the player's eye angle. For example, if the entity is upside down...
     * Realm: server.
     */
    public static inline function playerSelectSpawn(identifier:String, callback:(ply:Player, transition:Bool) -> Entity):Void
    {
        gmod.Hook.add("PlayerSelectSpawn", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Find a team spawn point entity for this player.
     * Realm: server.
     */
    public static inline function playerSelectTeamSpawn(identifier:String, callback:(team:Float, ply:Player) -> Entity):Void
    {
        gmod.Hook.add("PlayerSelectTeamSpawn", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever view model hands needs setting a model. By default this calls [PLAYER:GetHandsModel](https://wiki.facepunch.com/gmod/PLAYER:GetHandsModel) and if that fails, set...
     * Realm: server.
     */
    public static inline function playerSetHandsModel(identifier:String, callback:(ply:Player, ent:Entity) -> Void):Void
    {
        gmod.Hook.add("PlayerSetHandsModel", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever a player spawns and must choose a model. A good place to assign a model to a player. **NOTE**: This function may not work in your custom gamemode if you have ove...
     * Realm: server.
     */
    public static inline function playerSetModel(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PlayerSetModel", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Returns true if the player should take damage from the given attacker. **WARNING**: Applying damage from this hook to the player taking damage will lead to infinite loop/crash.
     * Realm: server.
     */
    public static inline function playerShouldTakeDamage(identifier:String, callback:(ply:Player, attacker:Entity) -> Bool):Void
    {
        gmod.Hook.add("PlayerShouldTakeDamage", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Allows to suppress player taunts.
     * Realm: server.
     */
    public static inline function playerShouldTaunt(identifier:String, callback:(ply:Player, act:Float) -> Bool):Void
    {
        gmod.Hook.add("PlayerShouldTaunt", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when the player is killed by [Player:KillSilent](https://wiki.facepunch.com/gmod/Player:KillSilent). The player is already considered dead when this hook is called. * See...
     * Realm: server.
     */
    public static inline function playerSilentDeath(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PlayerSilentDeath", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever a player spawns, including respawns. See [GM:PlayerInitialSpawn](https://wiki.facepunch.com/gmod/GM:PlayerInitialSpawn) for a hook called only the first time a p...
     * Realm: server.
     */
    public static inline function playerSpawn(identifier:String, callback:(player:Player, transition:Bool) -> Void):Void
    {
        gmod.Hook.add("PlayerSpawn", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called to spawn the player as a spectator.
     * Realm: server.
     */
    public static inline function playerSpawnAsSpectator(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PlayerSpawnAsSpectator", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Determines if the player can spray using the `impulse 201` console command.
     * Realm: server.
     */
    public static inline function playerSpray(identifier:String, callback:(sprayer:Player) -> Bool):Void
    {
        gmod.Hook.add("PlayerSpray", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when player starts taunting.
     * Realm: server.
     */
    public static inline function playerStartTaunt(identifier:String, callback:(ply:Player, act:Float, length:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerStartTaunt", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when a player starts using voice chat. See [GM:PlayerEndVoice](https://wiki.facepunch.com/gmod/GM:PlayerEndVoice) for the hook when the player stops talking. **NOTE**: Se...
     * Realm: client.
     */
    public static inline function playerStartVoice(identifier:String, callback:(ply:Player, ?plyIndex:Float) -> Void):Void
    {
        gmod.Hook.add("PlayerStartVoice", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Allows you to override the time between footsteps. See [GM:PlayerFootstep](https://wiki.facepunch.com/gmod/GM:PlayerFootstep) for a related hook about footstep sounds themselves...
     * Realm: shared.
     */
    public static inline function playerStepSoundTime(identifier:String, callback:(ply:Player, type:Float, walking:Bool) -> Float):Void
    {
        gmod.Hook.add("PlayerStepSoundTime", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called whenever a player attempts to either turn on or off their flashlight, returning false will deny the change. **NOTE**: Also gets called when using [Player:Flashlight](http...
     * Realm: server.
     */
    public static inline function playerSwitchFlashlight(identifier:String, callback:(ply:Player, enabled:Bool) -> Bool):Void
    {
        gmod.Hook.add("PlayerSwitchFlashlight", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player attempts to switch their weapon. Primary usage of this hook is to prevent/allow weapon switching, **not** to detect weapon switching. It will not be called ...
     * Realm: shared.
     */
    public static inline function playerSwitchWeapon(identifier:String, callback:(player:Player, oldWeapon:Weapon, newWeapon:Weapon) -> Bool):Void
    {
        gmod.Hook.add("PlayerSwitchWeapon", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * The Move hook is called for you to manipulate the player's [CMoveData](https://wiki.facepunch.com/gmod/CMoveData). This hook is called moments before [GM:Move](https://wiki.face...
     * Realm: shared.
     */
    public static inline function playerTick(identifier:String, callback:(player:Player, mv:CMoveData) -> Void):Void
    {
        gmod.Hook.add("PlayerTick", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a player has been hit by a trace and damaged (such as from a bullet). Returning true overrides the damage handling and prevents [GM:ScalePlayerDamage](https://wiki.f...
     * Realm: shared.
     */
    public static inline function playerTraceAttack(identifier:String, callback:(ply:Player, dmginfo:CTakeDamageInfo, dir:Vector, trace:gmod.generated.structs.TraceResult) -> Bool):Void
    {
        gmod.Hook.add("PlayerTraceAttack", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player unfreezes an object.
     * Realm: server.
     */
    public static inline function playerUnfrozeObject(identifier:String, callback:(ply:Player, ent:Entity, physobj:PhysObj) -> Void):Void
    {
        gmod.Hook.add("PlayerUnfrozeObject", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Triggered when the player presses use on an object. Continuously runs until USE is released but will not activate other Entities until the USE key is released; dependent on acti...
     * Realm: server.
     */
    public static inline function playerUse(identifier:String, callback:(ply:Player, ent:Entity) -> Bool):Void
    {
        gmod.Hook.add("PlayerUse", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when it's time to populate the context menu menu bar at the top.
     * Realm: client.
     */
    public static inline function populateMenuBar(identifier:String, callback:(menubar:Panel) -> Void):Void
    {
        gmod.Hook.add("PopulateMenuBar", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called right after the map has cleaned up (usually because [game.CleanUpMap](https://wiki.facepunch.com/gmod/game.CleanUpMap) was called) See also [GM:PreCleanupMap](https://wik...
     * Realm: shared.
     */
    public static inline function postCleanupMap(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostCleanupMap", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called right after the 2D skybox has been drawn - allowing you to draw over it.
     * Realm: client.
     */
    public static inline function postDraw2DSkyBox(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostDraw2DSkyBox", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after rendering effects. This is where halos are drawn. Called just before [GM:PreDrawHUD](https://wiki.facepunch.com/gmod/GM:PreDrawHUD) (The two hooks are basically ide...
     * Realm: client.
     */
    public static inline function postDrawEffects(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostDrawEffects", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after [GM:PreDrawHUD](https://wiki.facepunch.com/gmod/GM:PreDrawHUD), [GM:HUDPaintBackground](https://wiki.facepunch.com/gmod/GM:HUDPaintBackground) and [GM:HUDPaint](htt...
     * Realm: client.
     */
    public static inline function postDrawHUD(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostDrawHUD", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after drawing opaque entities. See also [GM:PostDrawTranslucentRenderables](https://wiki.facepunch.com/gmod/GM:PostDrawTranslucentRenderables) and [GM:PreDrawOpaqueRender...
     * Realm: client.
     */
    public static inline function postDrawOpaqueRenderables(identifier:String, callback:(bDrawingDepth:Bool, bDrawingSkybox:Bool, isDraw3DSkybox:Bool) -> Void):Void
    {
        gmod.Hook.add("PostDrawOpaqueRenderables", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after the player hands are drawn. See [GM:PostDrawViewModel](https://wiki.facepunch.com/gmod/GM:PostDrawViewModel) for the view model alternative. See [GM:PreDrawPlayerHa...
     * Realm: client.
     */
    public static inline function postDrawPlayerHands(identifier:String, callback:(hands:Entity, vm:Entity, ply:Player, weapon:Weapon, flags:Float) -> Void):Void
    {
        gmod.Hook.add("PostDrawPlayerHands", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after drawing the 3D skybox. This will not be called if skybox rendering was prevented via the [GM:PreDrawSkyBox](https://wiki.facepunch.com/gmod/GM:PreDrawSkyBox) hook. ...
     * Realm: client.
     */
    public static inline function postDrawSkyBox(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostDrawSkyBox", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after all translucent entities are drawn. See also [GM:PostDrawOpaqueRenderables](https://wiki.facepunch.com/gmod/GM:PostDrawOpaqueRenderables) and [GM:PreDrawTranslucent...
     * Realm: client.
     */
    public static inline function postDrawTranslucentRenderables(identifier:String, callback:(bDrawingDepth:Bool, bDrawingSkybox:Bool, isDraw3DSkybox:Bool) -> Void):Void
    {
        gmod.Hook.add("PostDrawTranslucentRenderables", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after view model is drawn. The render FOV in this hook is different from the main view, as view models are usually rendered with a different FOV. Every render operation w...
     * Realm: client.
     */
    public static inline function postDrawViewModel(identifier:String, callback:(viewmodel:Entity, player:Player, weapon:Weapon, flags:Float) -> Void):Void
    {
        gmod.Hook.add("PostDrawViewModel", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called every time a bullet pellet (i.e. this hook is called multiple times for a shotgun shot) is fired from an entity. Notably this hook will have the final damage and aim dire...
     * Realm: shared.
     */
    public static inline function postEntityFireBullets(identifier:String, callback:(entity:Entity, data:gmod.generated.structs.FiredBullet) -> Bool):Void
    {
        gmod.Hook.add("PostEntityFireBullets", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when an entity receives a damage event, after passing damage filters, etc. See [GM:EntityTakeDamage](https://wiki.facepunch.com/gmod/GM:EntityTakeDamage) if you wish to p...
     * Realm: server.
     */
    public static inline function postEntityTakeDamage(identifier:String, callback:(ent:Entity, dmginfo:CTakeDamageInfo, wasDamageTaken:Bool) -> Void):Void
    {
        gmod.Hook.add("PostEntityTakeDamage", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called after the gamemode has loaded.
     * Realm: shared.
     */
    public static inline function postGamemodeLoaded(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostGamemodeLoaded", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called right after [GM:DoPlayerDeath](https://wiki.facepunch.com/gmod/GM:DoPlayerDeath), [GM:PlayerDeath](https://wiki.facepunch.com/gmod/GM:PlayerDeath) and [GM:PlayerSilentDea...
     * Realm: server.
     */
    public static inline function postPlayerDeath(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("PostPlayerDeath", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after a given player in your [PVS (Potential Visibility Set)](https://developer.valvesoftware.com/wiki/PVS "PVS - Valve Developer Community") was drawn. This hook will no...
     * Realm: client.
     */
    public static inline function postPlayerDraw(identifier:String, callback:(ply:Player, flags:Float) -> Void):Void
    {
        gmod.Hook.add("PostPlayerDraw", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to suppress post processing effect drawing.
     * Realm: client.
     */
    public static inline function postProcessPermitted(identifier:String, callback:(effect_name:String) -> Bool):Void
    {
        gmod.Hook.add("PostProcessPermitted", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after the frame has been rendered. Will not be called if [GM:PreRender](https://wiki.facepunch.com/gmod/GM:PreRender) returned `true`, disabling all further rendering ope...
     * Realm: client.
     */
    public static inline function postRender(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostRender", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called after the VGUI has been drawn.
     * Realm: client.
     */
    public static inline function postRenderVGUI(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PostRenderVGUI", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called just after performing an undo.
     * Realm: server.
     */
    public static inline function postUndo(identifier:String, callback:(undo:Dynamic, count:Float) -> Void):Void
    {
        gmod.Hook.add("PostUndo", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called right before the map cleans up (usually because [game.CleanUpMap](https://wiki.facepunch.com/gmod/game.CleanUpMap) was called) See also [GM:PostCleanupMap](https://wiki.f...
     * Realm: shared.
     */
    public static inline function preCleanupMap(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PreCleanupMap", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called just after [GM:PreDrawViewModel](https://wiki.facepunch.com/gmod/GM:PreDrawViewModel) and can technically be considered as a "PostDrawAllViewModels". See [GM:PostDrawEffe...
     * Realm: client.
     */
    public static inline function preDrawEffects(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PreDrawEffects", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called just after [GM:PostDrawEffects](https://wiki.facepunch.com/gmod/GM:PostDrawEffects) (duplicate of it). Drawing anything in it seems to work incorrectly. See [GM:PostDrawH...
     * Realm: client.
     */
    public static inline function preDrawHUD(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PreDrawHUD", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before rendering the halos. This is the place to call [halo.Add](https://wiki.facepunch.com/gmod/halo.Add). This hook is actually running inside of [GM:PostDrawEffects](h...
     * Realm: client.
     */
    public static inline function preDrawHalos(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PreDrawHalos", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before all opaque entities are drawn. See also [GM:PreDrawTranslucentRenderables](https://wiki.facepunch.com/gmod/GM:PreDrawTranslucentRenderables) and [GM:PostDrawOpaque...
     * Realm: client.
     */
    public static inline function preDrawOpaqueRenderables(identifier:String, callback:(isDrawingDepth:Bool, isDrawSkybox:Bool, isDraw3DSkybox:Bool) -> Bool):Void
    {
        gmod.Hook.add("PreDrawOpaqueRenderables", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before the player hands are drawn. See [GM:PreDrawViewModel](https://wiki.facepunch.com/gmod/GM:PreDrawViewModel) for the view model alternative. See [GM:PostDrawPlayerHa...
     * Realm: client.
     */
    public static inline function preDrawPlayerHands(identifier:String, callback:(hands:Entity, vm:Entity, ply:Player, weapon:Weapon, flags:Float) -> Bool):Void
    {
        gmod.Hook.add("PreDrawPlayerHands", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before the 3D sky box is drawn. This will not be called for maps with no 3D skybox, or when the 3d skybox is disabled. (`r_3dsky 0`) See also [GM:PostDrawSkyBox](https://...
     * Realm: client.
     */
    public static inline function preDrawSkyBox(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("PreDrawSkyBox", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before all the translucent entities are drawn. See also [GM:PreDrawOpaqueRenderables](https://wiki.facepunch.com/gmod/GM:PreDrawOpaqueRenderables) and [GM:PostDrawTranslu...
     * Realm: client.
     */
    public static inline function preDrawTranslucentRenderables(identifier:String, callback:(isDrawingDepth:Bool, isDrawSkybox:Bool, isDraw3DSkybox:Bool) -> Bool):Void
    {
        gmod.Hook.add("PreDrawTranslucentRenderables", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before the view model has been drawn. By default this hook also calls [WEAPON:PreDrawViewModel](https://wiki.facepunch.com/gmod/WEAPON:PreDrawViewModel), so you can use t...
     * Realm: client.
     */
    public static inline function preDrawViewModel(identifier:String, callback:(vm:Entity, ply:Player, weapon:Weapon, flags:Float) -> Bool):Void
    {
        gmod.Hook.add("PreDrawViewModel", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called just before all view models (there are 3 per player, see [Player:GetViewModel](https://wiki.facepunch.com/gmod/Player:GetViewModel)) and entities with `RENDERGROUP_VIEWMO...
     * Realm: client.
     */
    public static inline function preDrawViewModels(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PreDrawViewModels", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called before the gamemode is loaded.
     * Realm: shared.
     */
    public static inline function preGamemodeLoaded(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("PreGamemodeLoaded", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before the player is drawn. See also [GM:PostPlayerDraw](https://wiki.facepunch.com/gmod/GM:PostPlayerDraw).
     * Realm: client.
     */
    public static inline function prePlayerDraw(identifier:String, callback:(player:Player, flags:Float) -> Bool):Void
    {
        gmod.Hook.add("PrePlayerDraw", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called by [scripted_ents.Register](https://wiki.facepunch.com/gmod/scripted_ents.Register).
     * Realm: shared.
     */
    public static inline function preRegisterSENT(identifier:String, callback:(ent:Dynamic, class_:String) -> Bool):Void
    {
        gmod.Hook.add("PreRegisterSENT", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a Scripted Weapon (SWEP) is about to be registered, allowing addons to alter the weapon's SWEP table with custom data for later usage. Called internally from [weapon...
     * Realm: shared.
     */
    public static inline function preRegisterSWEP(identifier:String, callback:(swep:Dynamic, class_:String) -> Bool):Void
    {
        gmod.Hook.add("PreRegisterSWEP", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called before the renderer is about to start rendering the next frame.
     * Realm: client.
     */
    public static inline function preRender(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("PreRender", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called just before performing an undo.
     * Realm: server.
     */
    public static inline function preUndo(identifier:String, callback:(undo:Dynamic) -> Bool):Void
    {
        gmod.Hook.add("PreUndo", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * This will prevent IN_ATTACK from sending to server when player tries to shoot from C menu.
     * Realm: client.
     */
    public static inline function preventScreenClicks(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("PreventScreenClicks", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when a prop has been destroyed.
     * Realm: shared.
     */
    public static inline function propBreak(identifier:String, callback:(attacker:Player, prop:Entity) -> Void):Void
    {
        gmod.Hook.add("PropBreak", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Render the scene. Used by the `Stereoscopy` post-processing effect. **NOTE**: Materials rendered in this hook require `$ignorez` parameter to draw properly.
     * Realm: client.
     */
    public static inline function renderScene(identifier:String, callback:(origin:Vector, angles:Angle, fov:Float) -> Bool):Void
    {
        gmod.Hook.add("RenderScene", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Used to render post processing effects.
     * Realm: client.
     */
    public static inline function renderScreenspaceEffects(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("RenderScreenspaceEffects", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when the game is reloaded from a Source Engine save system ( not the Sandbox saves or dupes ). See [GM:Saved](https://wiki.facepunch.com/gmod/GM:Saved) for a hook that is...
     * Realm: shared.
     */
    public static inline function restored(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("Restored", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when the game is saved using the Source Engine save system (not the Sandbox saves or dupes). See [GM:Restored](https://wiki.facepunch.com/gmod/GM:Restored) for a hook tha...
     * Realm: shared.
     */
    public static inline function saved(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("Saved", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when an NPC takes damage. **NOTE**: This hook is called only when a specific hit group of the NPC is hit. In cases where the hitgroup doesn't matter, you should use [GM:E...
     * Realm: server.
     */
    public static inline function scaleNPCDamage(identifier:String, callback:(npc:NPC, hitgroup:Float, dmginfo:CTakeDamageInfo) -> Void):Void
    {
        gmod.Hook.add("ScaleNPCDamage", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * This hook allows you to change how much damage a player receives when one takes damage to a specific body part. **NOTE**: This is called only for bullet damage a player receives...
     * Realm: shared.
     */
    public static inline function scalePlayerDamage(identifier:String, callback:(ply:Player, hitgroup:Float, dmginfo:CTakeDamageInfo) -> Bool):Void
    {
        gmod.Hook.add("ScalePlayerDamage", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when player released the scoreboard button (TAB by default).
     * Realm: client.
     */
    public static inline function scoreboardHide(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("ScoreboardHide", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when player presses the scoreboard button (TAB by default).
     * Realm: client.
     */
    public static inline function scoreboardShow(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("ScoreboardShow", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * An internal function used to send a death notice event to all clients.
     * Realm: server.
     */
    public static inline function sendDeathNotice(identifier:String, callback:(attacker:Dynamic, inflictor:String, victim:Dynamic, flags:Float) -> Void):Void
    {
        gmod.Hook.add("SendDeathNotice", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Sets player run and sprint speeds. Using a speed of `0` can lead to prediction errors, and can cause players to move at `sv_maxvelocity` **WARNING**: This is not a hook. Treat t...
     * Realm: shared.
     */
    public static inline function setPlayerSpeed(identifier:String, callback:(ply:Player, walkSpeed:Float, runSpeed:Float) -> Void):Void
    {
        gmod.Hook.add("SetPlayerSpeed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * SetupMove is called before the engine process movements. This allows us to override the players movement. See [Game Movement](https://wiki.facepunch.com/gmod/Game_Movement) for ...
     * Realm: shared.
     */
    public static inline function setupMove(identifier:String, callback:(ply:Player, mv:CMoveData, cmd:CUserCmd) -> Void):Void
    {
        gmod.Hook.add("SetupMove", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Allows you to add extra positions to the player's [PVS (Potential Visibility Set)](https://developer.valvesoftware.com/wiki/PVS "PVS - Valve Developer Community"). This is the p...
     * Realm: server.
     */
    public static inline function setupPlayerVisibility(identifier:String, callback:(ply:Player, viewEntity:Entity) -> Void):Void
    {
        gmod.Hook.add("SetupPlayerVisibility", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to use render.Fog* functions to manipulate skybox fog. 		This will not be called for maps with no 3D skybox, or when the 3d skybox is disabled. (`r_3dsky 0`)
     * Realm: client.
     */
    public static inline function setupSkyboxFog(identifier:String, callback:(scale:Float) -> Bool):Void
    {
        gmod.Hook.add("SetupSkyboxFog", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Allows you to use render.Fog* functions to manipulate world fog.
     * Realm: client.
     */
    public static inline function setupWorldFog(identifier:String, callback:() -> Bool):Void
    {
        gmod.Hook.add("SetupWorldFog", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called to decide whether a pair of entities should collide with each other. This is only called if [Entity:SetCustomCollisionCheck](https://wiki.facepunch.com/gmod/Entity:SetCus...
     * Realm: shared.
     */
    public static inline function shouldCollide(identifier:String, callback:(ent1:Entity, ent2:Entity) -> Bool):Void
    {
        gmod.Hook.add("ShouldCollide", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called to determine if the [Global.LocalPlayer](https://wiki.facepunch.com/gmod/Global.LocalPlayer) should be drawn. If you're using this hook to draw a player for a [GM:CalcVie...
     * Realm: client.
     */
    public static inline function shouldDrawLocalPlayer(identifier:String, callback:(ply:Player) -> Bool):Void
    {
        gmod.Hook.add("ShouldDrawLocalPlayer", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player executes `gm_showhelp` console command. (Default bind is F1)
     * Realm: server.
     */
    public static inline function showHelp(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("ShowHelp", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player executes `gm_showspare1` console command ( Default bind is F3 ).
     * Realm: server.
     */
    public static inline function showSpare1(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("ShowSpare1", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player executes `gm_showspare2` console command ( Default bind is F4 ).
     * Realm: server.
     */
    public static inline function showSpare2(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("ShowSpare2", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a player executes `gm_showteam` console command. ( Default bind is F2 )
     * Realm: server.
     */
    public static inline function showTeam(identifier:String, callback:(ply:Player) -> Void):Void
    {
        gmod.Hook.add("ShowTeam", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called whenever the Lua environment is about to be shut down, for example on map change, or when the server is going to shut down.
     * Realm: shared.
     */
    public static inline function shutDown(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("ShutDown", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when the Spawnmenu is Created.
     * Realm: client.
     */
    public static inline function spawnMenuCreated(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("SpawnMenuCreated", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when spawn icon is generated.
     * Realm: client.
     */
    public static inline function spawniconGenerated(identifier:String, callback:(lastmodel:String, imagename:String, modelsleft:Float) -> Void):Void
    {
        gmod.Hook.add("SpawniconGenerated", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Runs when the user tries to open the chat box. **WARNING**: Returning `true` won't stop the chatbox from taking VGUI focus. [chat.Close](https://wiki.facepunch.com/gmod/chat.Clo...
     * Realm: client.
     */
    public static inline function startChat(identifier:String, callback:(isTeamChat:Bool) -> Bool):Void
    {
        gmod.Hook.add("StartChat", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Allows you to change the players inputs before they are processed by the server. This function is also called for bots, making it the best solution to control them. This is basi...
     * Realm: shared.
     */
    public static inline function startCommand(identifier:String, callback:(ply:Player, ucmd:CUserCmd) -> Void):Void
    {
        gmod.Hook.add("StartCommand", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called right before an entity starts driving. Overriding this hook will cause it to not call [drive.Start](https://wiki.facepunch.com/gmod/drive.Start) and the player will not b...
     * Realm: shared.
     */
    public static inline function startEntityDriving(identifier:String, callback:(ent:Entity, ply:Player) -> Void):Void
    {
        gmod.Hook.add("StartEntityDriving", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when you start a new game via the menu.
     * Realm: menu.
     */
    public static inline function startGame(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("StartGame", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client || gmod_menu)
    /**
     * Called every rendered frame on client, except when the game is paused. Called every game tick on the server. This will be the same as [GM:Tick](https://wiki.facepunch.com/gmod/G...
     * Realm: shared and menu.
     */
    public static inline function think(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("Think", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called every game tick. [engine.TickCount](https://wiki.facepunch.com/gmod/engine.TickCount) is guaranteed to be different between each call. Server side, this is similar to [GM...
     * Realm: shared.
     */
    public static inline function tick(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("Tick", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * **NOTE**: Isn't called when CalcMainActivity returns a valid override sequence id 		Allows you to translate player activities.
     * Realm: shared.
     */
    public static inline function translateActivity(identifier:String, callback:(ply:Player, act:Float) -> Float):Void
    {
        gmod.Hook.add("TranslateActivity", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Animation updates (pose params etc) should be done here.
     * Realm: shared.
     */
    public static inline function updateAnimation(identifier:String, callback:(ply:Player, velocity:Vector, maxSeqGroundSpeed:Float) -> Void):Void
    {
        gmod.Hook.add("UpdateAnimation", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client)
    /**
     * Called when user clicks on a VGUI panel.
     * Realm: client.
     */
    public static inline function vGUIMousePressAllowed(identifier:String, callback:(button:Float) -> Bool):Void
    {
        gmod.Hook.add("VGUIMousePressAllowed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_client || gmod_menu)
    /**
     * Called when a mouse button is pressed on a VGUI element or menu.
     * Realm: client and menu.
     */
    public static inline function vGUIMousePressed(identifier:String, callback:(pnl:Panel, mouseCode:Float) -> Void):Void
    {
        gmod.Hook.add("VGUIMousePressed", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called when a variable is edited on an Entity (called by Edit Properties... menu). See [Editable Entities](https://wiki.facepunch.com/gmod/Editable_Entities) for more informatio...
     * Realm: server.
     */
    public static inline function variableEdited(identifier:String, callback:(ent:Entity, ply:Player, key:String, val:String, editor:Dynamic) -> Void):Void
    {
        gmod.Hook.add("VariableEdited", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server || gmod_client)
    /**
     * Called when you are driving a vehicle. This hook works just like [GM:Move](https://wiki.facepunch.com/gmod/GM:Move). This hook is called before [GM:Move](https://wiki.facepunch....
     * Realm: shared.
     */
    public static inline function vehicleMove(identifier:String, callback:(ply:Player, veh:Vehicle, mv:CMoveData) -> Void):Void
    {
        gmod.Hook.add("VehicleMove", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_server)
    /**
     * Called as a weapon entity is picked up by a player. (Including [Player:Give](https://wiki.facepunch.com/gmod/Player:Give)) Contrary to the name of the hook, it is **not called**...
     * Realm: server.
     */
    public static inline function weaponEquip(identifier:String, callback:(weapon:Weapon, owner:Player) -> Void):Void
    {
        gmod.Hook.add("WeaponEquip", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when an addon from the Steam workshop begins downloading. Used by default to place details on the workshop downloading panel.
     * Realm: menu.
     */
    public static inline function workshopDownloadFile(identifier:String, callback:(id:Float, imageID:Float, title:String, size:Float) -> Void):Void
    {
        gmod.Hook.add("WorkshopDownloadFile", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called while an addon from the Steam workshop is downloading. Used by default to update details on the fancy workshop download panel.
     * Realm: menu.
     */
    public static inline function workshopDownloadProgress(identifier:String, callback:(id:Float, imageID:Float, title:String, downloaded:Float, expected:Float) -> Void):Void
    {
        gmod.Hook.add("WorkshopDownloadProgress", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called after [GM:WorkshopStart](https://wiki.facepunch.com/gmod/GM:WorkshopStart).
     * Realm: menu.
     */
    public static inline function workshopDownloadTotals(identifier:String, callback:(remain:Float, total:Float) -> Void):Void
    {
        gmod.Hook.add("WorkshopDownloadTotals", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when an addon from the Steam workshop finishes downloading. Used by default to update details on the workshop downloading panel.
     * Realm: menu.
     */
    public static inline function workshopDownloadedFile(identifier:String, callback:(id:Float, title:String) -> Void):Void
    {
        gmod.Hook.add("WorkshopDownloadedFile", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when downloading content from Steam workshop ends. Used by default to hide fancy workshop downloading panel.
     * Realm: menu.
     */
    public static inline function workshopEnd(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("WorkshopEnd", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called while an addon from the Steam workshop is extracting. Used by default to update details on the fancy workshop download panel.
     * Realm: menu.
     */
    public static inline function workshopExtractProgress(identifier:String, callback:(id:Float, ImageID:Float, title:String, percent:Float) -> Void):Void
    {
        gmod.Hook.add("WorkshopExtractProgress", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when downloading content from Steam workshop begins. Used by default to show fancy workshop downloading panel. The order of Workshop hooks is this: * WorkshopStart * Work...
     * Realm: menu.
     */
    public static inline function workshopStart(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("WorkshopStart", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when UGC subscription status changes.
     * Realm: menu.
     */
    public static inline function workshopSubscriptionsChanged(identifier:String, callback:() -> Void):Void
    {
        gmod.Hook.add("WorkshopSubscriptionsChanged", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * Called when a Workshop Message is received?. Currently, it seems like the message will be **#ugc.mounting** every time. 		When does this exactly get called?. If an addon is subs...
     * Realm: menu.
     */
    public static inline function workshopSubscriptionsMessage(identifier:String, callback:(message:String) -> Void):Void
    {
        gmod.Hook.add("WorkshopSubscriptionsMessage", identifier, callback);
    }
#end

#if (!gmod_realm_strict || gmod_menu)
    /**
     * **INTERNAL**: This is used internally - although you're able to use it you probably shouldn't. Called by the engine when the game initially fetches subscriptions to be displayed...
     * Realm: menu.
     */
    public static inline function workshopSubscriptionsProgress(identifier:String, callback:(num:Float, max:Float) -> Void):Void
    {
        gmod.Hook.add("WorkshopSubscriptionsProgress", identifier, callback);
    }
#end

}
