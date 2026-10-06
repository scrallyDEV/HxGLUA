# Learn HxGMod

Run `hxgmod build --package` here, then install `dist/hx_learning` as an addon.
The shared autorun prints `Enemy call: 1`, `Direct call: 2`, `Shared calls: 2`
independently on client and server when first loaded.

`Enemy.hx` imports `PlayerVar.hx` with ordinary Haxe syntax. Each has its own
generated Lua file, and the autorun needs no manual dependency includes. The
PlayerVar static counter is one instance per realm, shared by both callers.
The `hx_learning` path prefix avoids collisions in GMod's merged Lua filesystem.

Try the `hx_learning_hello` server console command. The server hook prints
`Initialized`. In Sandbox, look under the HxGMod category for `hx_learning_prop`
and `weapon_hx_learning_tool`. The prop is a physics barrel with the bundled
blue material; the weapon is a training tool with no attacks.

```text
hxgmod.json
src/lua/
  autorun/                       # shared linker demonstration
    server/                      # hook and command examples
  hx_learning/player/PlayerVar.hx # shared module state
  hx_learning/enemy/Enemy.hx      # imports PlayerVar
  entities/hx_learning_prop/     # normal GMod loaders
  weapons/weapon_hx_learning_tool/
materials/hx_learning/blue.vmt   # copied automatically
```

See [CUSTOM_MODEL.md](CUSTOM_MODEL.md) to replace the barrel with your own
GMod-compatible model, keeping its companion files together. No downloaded model
or copyrighted third-party asset is bundled. `src/shared/` is unnecessary here;
create it only when you want ordinary bundled helper code.

The tiny lowercase autorun retains the supported Main loader form; generated
hook/command scripts demonstrate ordinary named modules. Server/client state is
separate. Restart the realm after changing a cached named module.

After install, verify the three linking counts, entity physics/appearance, weapon
spawn menu and client content delivery inside GMod. Standalone Lua tests cannot
verify those engine behaviors. The older `examples/learning` remains a legacy demo.
