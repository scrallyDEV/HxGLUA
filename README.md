# HxGMod

Haxe → Lua 5.1 / LuaJIT for Garry's Mod. The SDK contains the bindings and tools;
your addon or gamemode contains only your source, configuration, and assets.

## Install on Windows

Install Haxe (tested with **4.3.7**) and Python **3.10+**, with both on PATH.
Keep this SDK in a permanent folder, then run in PowerShell:

```powershell
cd 'C:\HaxeToolkit\haxe\lib\HxGLUA'
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

Setup registers `hxgmod` with haxelib and adds this SDK to your **user** PATH.
Open a new terminal. It does not need administrator privileges if you can write
to your haxelib repository. `setup.ps1 -NoPath` registers without changing PATH.
If Python's Windows App Execution Alias opens the Store, install Python and fix
that alias first. This SDK needs no hxjava, LuaRocks, Node, or custom Lua compiler.

```powershell
hxgmod doctor
cd 'E:\WSS (SSD)\Creations'
hxgmod new addon my_addon
cd my_addon
hxgmod build --package
hxgmod install 'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod'
```

For a gamemode: `hxgmod new gamemode my_mode --title "My Mode" --base sandbox`.
Build and install it the same way. Set `install_path` in `hxgmod.json` to omit
the install argument. A relative install path is relative to the project root.

## Daily commands

| Command | Result |
| --- | --- |
| `hxgmod new addon NAME [DIRECTORY]` | Minimal project; directory may contain spaces |
| `hxgmod new gamemode NAME [DIRECTORY]` | Minimal gamemode project |
| `hxgmod add entity NAME` / `add swep NAME` | Minimal spawnable entity or training weapon |
| `hxgmod add autorun NAME --realm server` | Named server script; client/shared also supported |
| `hxgmod add hook NAME` / `add command NAME` | Minimal callback examples |
| `hxgmod build` | Compile every mirrored entry (legacy projects retain bundles/targets) |
| `hxgmod build server` / `client` | Quick realm check; cannot package until a full build |
| `hxgmod build --package` | Compile everything, then assemble `dist/NAME` |
| `hxgmod build --install [PATH]` | Compile, package, install; omitted PATH uses config |
| `hxgmod package` | Package a complete, unchanged build; never compiles implicitly |
| `hxgmod install [PATH]` | Package a complete, unchanged build and install it |
| `hxgmod clean` | Remove project `build/` and `dist/` |
| `hxgmod doctor` | Check tools, exact library registration, PATH and project |
| `hxgmod update` | Download latest API, regenerate and type-check bindings before replacing |
| `hxgmod update --offline` | Regenerate and check using the cached API |
| `hxgmod register` / `unregister` | Set/remove the haxelib development override |

`hxgmod --project "PATH/my addon" build --package` selects a project from elsewhere.
`hxgmod --verbose build` shows compiler commands. Version reporting reads the same
metadata as haxelib; this is an unreleased 1.0 readiness pass, not a published 1.0.

Commands find `hxgmod.json` in the current directory or its parents. Names use
lowercase letters, digits, underscores and hyphens; Windows device names are rejected.
The package is a directory, not a Workshop `.gma`; use GMod's publishing tools afterward.

## Source layout

New scaffolds use `"source_layout": "filesystem"`. One mirrored `.hx` entry becomes
one `.lua` file with the same relative path:

```text
Addon source                              dist/NAME/
src/lua/autorun/server/startup.hx       -> lua/autorun/server/startup.lua
src/lua/myaddon/debug.hx                -> lua/myaddon/debug.lua
src/lua/entities/my_entity/init.hx      -> lua/entities/my_entity/init.lua
src/lua/weapons/weapon_example/shared.hx -> lua/weapons/weapon_example/shared.lua

Gamemode source
src/gamemode-root/gamemode/init.hx      -> gamemode/init.lua
src/gamemode-root/entities/entities/my_entity/init.hx
                                       -> entities/entities/my_entity/init.lua
```

Named mirrored modules use normal Haxe filenames, packages and imports. Imported
mirrored implementations stay in their own Lua file and load automatically once
per realm, sharing their static state. See `examples/hx_learning`.
Lowercase loaders retain `package; class Main { static function main():Void { ... } }`;
the CLI stages those as `Main.hx` to support ordinary GMod filenames.
Helpers elsewhere in `src/` are imported and bundled only where used. Raw Lua stays
in `lua/`. Put assets directly in `models/`, `materials/`, `sound/`, `resource/`,
`particles/`, or `maps/`; packaging copies every file (under `content/` for gamemodes).
`package-root/` still copies verbatim. Collisions fail.
New scaffolds do not use HXML or configured entity/weapon targets. The addon starter
is one named server autorun. `src/shared/` is optional bundled helper space; it is
not a GMod directory and is not created unless you need it.

`server/`, `client/`, `init.hx`, and `cl_init.hx` select realms. Other entries compile
strictly for both realms into one runtime-selected Lua file. Use `#if gmod_server`
and `#if gmod_client` for realm-specific APIs. Client transfer is automatic; execution
and shared-file includes follow the GMod loaders and your explicit `include` calls.

See [filesystem sources and migration](docs/filesystem.md) for complete examples,
loader conventions, and the exact gamemode root. Existing 0.3.0 configs without
`source_layout` keep the deprecated legacy build. `-lib hxgmod` still exposes only
the SDK's library-only `src/`, and public `gmod.*` aliases are unchanged.

## Models and materials

Copy a ready-to-use model's complete `models/` and `materials/` directories into
your project. Run `hxgmod build --package` and install. No lists, manual dist edits,
or conversion step. Use `self.setModel("models/my_addon/prop.mdl")` in your entity.
Keep all supplied companion files; client downloads still use normal GMod resource
APIs. See [assets and custom models](docs/assets.md) for the complete workflow.

## The four rules

- Mirrored Haxe file → physical Lua module.
- Import a mirrored module → call its separately generated implementation.
- Import an ordinary helper → its implementation may be bundled in each caller.
- Normal GMod loader rules still apply; sending a file does not execute it.

## Learn and troubleshoot

- [Quickstart, generators, entity/SWEP and helper recipes](docs/quickstart.md)
- [External models, materials and client downloads](docs/assets.md)
- [Filesystem sources, includes, and migration](docs/filesystem.md)
- [Legacy entities, weapons, and NextBots](docs/targets.md)
- [Packaging, raw Lua, installation, and runtime boundaries](docs/workflows.md)
- [Bindings, regeneration, and verification](docs/bindings.md)
- [Troubleshooting and migration](docs/troubleshooting.md)

`examples/learning` is a legacy compatibility addon with a physics barrel, a training SWEP
with no attacks, and a stationary NextBot. Build it with `hxgmod build --package` from its
directory. All examples are outside the library classpath.

`examples/hx_learning` is the recommended small tutorial: linked modules, a hook,
a console command, an entity, a SWEP and an original material. See [release notes](CHANGELOG.md).
