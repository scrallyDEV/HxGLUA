# Filesystem sources

New projects use `"source_layout": "filesystem"` in `hxgmod.json`.
One mirrored `.hx` entry produces one physical `.lua` file, at the same relative
path. Named Haxe modules inside the mirrored root link to one another using normal
Haxe imports. Helpers outside that root are still bundled where used.

## Exact roots

| Source | Destination under `dist/NAME/` |
| --- | --- |
| Addon `src/lua/PATH.hx` | `lua/PATH.lua` |
| Gamemode `src/gamemode-root/PATH.hx` | `PATH.lua` |
| Raw `lua/PATH.lua` | addon `lua/PATH.lua`; gamemode `gamemode/PATH.lua` |
| Raw/assets `package-root/PATH` | `PATH` |
| `models/`, `materials/`, `sound/`, `resource/`, `particles/`, `maps/` | same folder in addon; `content/` prefix in gamemode |
| Helpers elsewhere in `src/` | no standalone output; bundled when imported |

Gamemode root means the directory containing `NAME.txt`, `gamemode/`, `entities/`,
and `content/`. The CLI generates `NAME.txt` from the existing `gamemode` config.
Put assets in the conventional project folders above (see [assets](assets.md)),
not in a mirrored source tree. `package-root/` remains supported unchanged. All mirrored `.hx`
files produce outputs; keep intentionally bundled helpers outside those roots.

## Named modules and imports

```haxe
// src/lua/player/PlayerVar.hx -> lua/player/PlayerVar.lua
package player;
class PlayerVar {
    public static var health:Int = 100;
    public static function someFunction():Int { return ++health; }
}
```

```haxe
// src/lua/enemy/Enemy.hx -> lua/enemy/Enemy.lua
package enemy;
import player.PlayerVar;
class Enemy {
    public static function main():Void {
        lua.Lua.print(PlayerVar.someFunction());
    }
}
```

Use normal capitalized filenames and packages relative to `src/lua/` (or
`src/gamemode-root/`). Importing a mirrored module preserves Haxe typing but emits
references to its separately loaded Lua implementation. Enemy contains no copy of
PlayerVar. A named module's optional static `main()` runs once after its static
initializers, when GMod or another module first loads it. No main is required for
a library module. An unused import does not cause execution.
Root `Main` is reserved when legacy Main loaders coexist; put a named Main in a
package in that case.

Dependencies load automatically with GMod `include` before the caller initializes.
A registry scoped by project location, project name and realm caches each named
module's exported types, including mutable static fields. Multiple callers share
one instance in that realm; unrelated projects with identical type names do not.
Distribution needs only the generated Lua files, not the build-machine paths.
Existing lowercase `Main` loaders can import named modules too; they continue to
execute on each explicit include, which preserves ENT/SWEP loader behavior.

The compiler excludes foreign mirrored implementations before generation and
keeps exported members in their owning module. Mirrored inline methods are emitted
as calls to preserve the boundary; inline constants remain compile-time values.
Ordinary helper inlining and bundling are unchanged.

Runtime dependency cycles fail the build with the cycle path (including method
dependencies, even if a particular method would not run). Dynamic include cycles
and failed module initialization also fail clearly at runtime; failed modules are
not retried automatically. Cross-realm runtime dependencies fail compilation;
guard references with `#if gmod_server` / `#if gmod_client`. Output files also guard
their realm. Client/shared transfer lists still send files without executing them.

Limitations: use ordinary classes/enums for linked implementations. Executable
abstracts, `@:generic` specialization, mirrored `@:native` types and `@:extern`
methods are rejected. Helpers
and Haxe runtime support remain private per output; helper class identity and
runtime reflection are not a shared cross-module ABI. Do not rely on reflection
by original type name across files. Cached named modules are not hot-reloaded by
repeated include; restart the Lua realm after changing their implementation.
GMod's merged Lua filesystem still requires project-specific physical paths.
See `examples/hx_learning` for a minimal runnable example.

## Entry syntax (including lowercase filenames)

Existing loader files use the empty package and `class Main` with `static main()`:

```haxe
// src/lua/myaddon/debug.hx -> lua/myaddon/debug.lua
package;
class Main {
    static function main():Void {
        shared.SharedMain.init(); // imports a helper from src/shared/SharedMain.hx
        lua.Lua.print("debug file loaded");
    }
}
```

Haxe normally requires capitalized module filenames. The CLI copies each legacy loader to
an isolated temporary `Main.hx` before invoking Haxe. The original filename and
directory determine the output, not the class name. Compiler error paths may
therefore mention `build/entry-.../Main.hx`; the build runs entries in sorted order.
Line numbers match the original file. Named modules compile at their original
source paths; each output is compiled independently with linking metadata.
Project `src/` takes precedence over library sources; the temporary entry takes
precedence over a project `Main.hx`. New projects do not need HXML files.

## Realms and includes

Directory components `server/` and `client/` select that realm (server wins if both
appear; avoid such ambiguous paths). Otherwise `init.hx` selects server and
`cl_init.hx` selects client. All other paths, including `shared.hx`, compile for
both realms with strict checks. Guard realm-only APIs with `#if gmod_server` or
`#if gmod_client`. A shared output contains both isolated compiled branches inside
`if SERVER then ... else ... end`; it is still one physical Lua file.

Use output `.lua` paths when including files:

```haxe
gmod.LuaScripts.include("myaddon/debug.lua");
// In an entity, weapon, or gamemode init/cl_init:
gmod.LuaScripts.include("shared.lua");
```

Explicit includes execute loaders/raw Lua. Named mirrored modules initialize once;
Haxe imports of helpers outside the mirrored root still bundle them into callers,
with private helper state in each output. Shared does not mean shared memory
between client and server realms.
The existing isolated runtime environment and public `gmod.*` imports are retained.

The CLI sends all client/shared Lua files (including raw files) using a generated
addon `lua/autorun/server/NAME_hxgmod_transfer.lua`, or a prefix in gamemode `init.lua`.
Transfer does **not** execute files. Provide explicit includes and normal GMod
loaders. There are no implicit entity/weapon loaders or implicit shared includes.
Server-only files are excluded from transfer. Raw files use the same realm naming
rules; unconventional runtime loading needs explicit `AddCSLuaFile` calls.
Avoid secret/server-only content in shared paths: both compiled branches are sent.

## Addon example

```text
hxgmod.json                 # source_layout: filesystem, project_type: addon
src/shared/SharedMain.hx     # imported helper, no emitted file
src/lua/autorun/server/myaddon_start.hx
src/lua/autorun/client/myaddon_start.hx
src/lua/myaddon/debug.hx
src/lua/entities/my_entity/init.hx
src/lua/entities/my_entity/cl_init.hx
src/lua/entities/my_entity/shared.hx
src/lua/weapons/weapon_example/init.hx
src/lua/weapons/weapon_example/cl_init.hx
src/lua/weapons/weapon_example/shared.hx
lua/myaddon/raw.lua
package-root/materials/myaddon/...
```

Entity `init.hx` and `cl_init.hx` can each include `shared.lua`. Its mirrored
`shared.hx` main sets `gmod.ENT` fields and callbacks, using realm guards as needed.
Weapons work the same way with `gmod.SWEP`. Include order is yours to control.

## Gamemode example

```text
hxgmod.json                 # source_layout: filesystem, project_type: gamemode
src/shared/SharedMain.hx
src/gamemode-root/gamemode/init.hx
src/gamemode-root/gamemode/cl_init.hx
src/gamemode-root/gamemode/shared.hx
src/gamemode-root/entities/entities/my_entity/init.hx
src/gamemode-root/entities/entities/my_entity/cl_init.hx
src/gamemode-root/entities/entities/my_entity/shared.hx
src/gamemode-root/entities/weapons/weapon_example/shared.hx
package-root/content/materials/...
```

The new gamemode scaffold provides init/cl_init that include shared.lua. The shared
entry calls `DeriveGamemode` using the requested scaffold base. If changing the base
later, update that call as well as the `gamemode.base` descriptor setting.
Both init and cl_init are required, either mirrored or raw. Entity/weapon loaders
are authored normally; a single shared weapon definition can use GMod's normal
loader conventions. See [GMod folder structure](https://wiki.facepunch.com/gmod/Lua_Folder_Structure)
and [include path rules](https://wiki.facepunch.com/gmod/Global.include).

## Build, collisions, and migration

```powershell
hxgmod doctor
hxgmod build --package
hxgmod package
hxgmod install 'C:\path\to\GarrysMod\garrysmod'
```

`build server` and `build client` are compile checks only; only a full `build`
permits packaging. Packaging uses the current discovered outputs, so removed entries
disappear from the next package. Failed builds invalidate freshness without replacing
the last valid dist. The existing staged packaging and tracked-install safety remain.

Duplicate output paths are errors, including case-only, file-versus-directory,
raw-versus-compiled, and entity/weapon single-file-versus-folder definitions.
The transfer filename and gamemode descriptor are reserved. Doctor checks these
before compilation. Raw roots cannot contain symlinks/junctions.

Existing 0.3.0 projects without `source_layout` retain the legacy HXML and configured
target build, with a deprecation notice. `examples/learning` remains a legacy
compatibility example. To migrate:

1. Set `"source_layout": "filesystem"` and remove `entities`/`weapons` config maps.
2. Move the old realm entry bodies into mirrored autoruns (addon) or init/cl_init
   (gamemode). Use `package; class Main { static function main() ... }` per file.
3. Keep reusable classes under ordinary `src/` paths. For each old target, write
   mirrored init/cl_init loaders that include shared.lua; its entry can call the
   old helper's `main()`. This preserves its guarded callbacks with minimal editing.
4. Back up/remove old build-server.hxml and build-client.hxml; filesystem builds
   ignore HXML. Keep raw `lua/` and `package-root/`, resolving any reported collision.
5. Run `hxgmod doctor`, then `hxgmod build --package`. Test the package in GMod.

Custom HXML/library flags are only supported by the legacy build path in this
focused change. Setup, library-only exposure, bindings, generator, aliases, and
installation ownership rules are unchanged.
