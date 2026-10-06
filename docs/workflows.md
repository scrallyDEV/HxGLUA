# Package and install

For new filesystem projects, start with [filesystem sources and migration](filesystem.md).
The bundle/HXML/configured-target instructions below describe the retained legacy
0.3.0 layout. Packaging and install safety still apply to both layouts.

`hxgmod build --package` produces `dist/NAME`. A full build compiles every mirrored source in its applicable realms (or every
configured bundle/target for legacy projects). A failed or partial build invalidates
packaging. Editing source, configuration, raw assets, HXML, or SDK bindings requires
a new full build. This deliberately favors predictable output over incremental builds.

| Output | Addon | Gamemode |
| --- | --- | --- |
| Server | `lua/autorun/server/NAME_server.lua` | `gamemode/init.lua` |
| Client | `lua/autorun/client/NAME_client.lua` | `gamemode/cl_init.lua` |
| Descriptor | none | `NAME.txt` |
| Entity | `lua/entities/CLASS/{init,cl_init}.lua` | `entities/entities/CLASS/{init,cl_init}.lua` |
| Weapon | `lua/weapons/CLASS/{init,cl_init}.lua` | `entities/weapons/CLASS/{init,cl_init}.lua` |

Gamemode entrypoints call `DeriveGamemode`; the server sends the client entrypoint.
Addon server autorun explicitly sends its client bundle. Raw helper files are your
responsibility to send/include where appropriate.

Autorun filenames include the project name so multiple HxGMod addons can coexist in
GMod's merged Lua filesystem. Internal `build/server/hxgmod_server.lua` and client
build output names remain unchanged. Use unique project, entity, weapon, and hook IDs.

Packaging is staged and checks collisions before replacing the last valid package.
Raw and compiled files may not collide, including case-only differences. Configured
entity/weapon class folders are reserved in full; a raw single-file definition for
the same class is also rejected. Renaming/removing a target removes old packaged
files on the next successful build/package.

## Raw Lua and assets

- Project `lua/` → addon `lua/`, or gamemode `gamemode/`.
- Project `models/`, `materials/`, `sound/`, `resource/`, `particles/`, `maps/` →
  matching addon folders or gamemode `content/` folders. See [asset workflow](assets.md).
- Project `package-root/` → package root verbatim, including raw gamemode `entities/`
  trees. Legacy gamemode assets should be under `package-root/content/`.
- Do not define the same destination in both raw trees. Links/junctions are not supported.

```haxe
import gmod.LuaScripts;

#if gmod_server
LuaScripts.addCSLuaFile("helpers/shared.lua");
#end
var helper:Dynamic = LuaScripts.include("helpers/shared.lua");
// LuaScripts.require("module_name") loads an installed GLua module.
```

An ordinary Lua helper should return a table if Haxe needs its functions. Include
paths inside an entity follow GMod's entity-relative rules. Include does not
automatically send a file to clients; AddCSLuaFile does not execute it.
See [Facepunch's explanation](https://wiki.facepunch.com/gmod/Understanding_AddCSLuaFile_and_include).

## Runtime boundaries

Every packaged Haxe bundle has its own Lua 5.1 environment with reads falling back
to GMod globals. This keeps Haxe runtime globals from overwriting another bundle's
helpers. `ENT` and `SWEP` are captured from the active GMod loader context. Raw
include files still run under GMod's loader. Explicit `_G` writes are possible for
intentional cross-bundle interop; prefer native Lua tables and engine APIs.

Ordinary bundled helpers have bundle-local state and identity. Named mirrored
modules instead load once per realm and share their static state across callers.
See [module imports](filesystem.md). `@:expose` writes
to the real global table and should be used carefully. Do not exchange Haxe arrays
as engine sequence tables: use `gmod.NativeSequence<T>` (native 1-based indexing).

The runtime target is stock Lua 5.1/LuaJIT, not GLua-only syntax. `lua-vanilla`
avoids compiled UTF-8 dependencies; string operations follow Haxe's vanilla Lua
behavior, not a Unicode text library. GMod APIs remain available through externs.

## Install safely

Pass a `garrysmod` root, the parent game directory containing it, or the matching
`addons` / `gamemodes` directory. The CLI installs under `NAME` and records ownership
and file hashes in `.hxgmod-install.json`. A repeat install replaces only an unchanged
installation owned by this source project. Untracked folders, another source project's
installation, and manual edits are refused: move the existing folder to a backup
location first. The CLI never deletes an arbitrary existing addon to adopt it.

Packages and install folders are replaced using sibling staging/backup directories.
If a previous `.hxgmod-old` remains after an interrupted operation, inspect it before
retrying. Do not run simultaneous builds, updates, or installs against the same project.
