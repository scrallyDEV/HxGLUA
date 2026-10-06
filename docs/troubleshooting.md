# Troubleshooting and migration

Start with `hxgmod doctor` from anywhere inside your project. Use
`hxgmod --verbose build` for compiler details. Haxe and Python are required;
hxjava/JDK are not needed for GLua.

## Assets missing or showing the error model

Use `models/`, `materials/`, **`sound/`**, `resource/`, `particles/` or `maps/`
beside hxgmod.json, then `hxgmod build --package` again. `assets/`, `sounds/` and
runtime `data/` are not automatic package roots. Keep model companions and the
author's material paths. Check client downloads separately from server installation.
See [assets](assets.md). Doctor reports common folder typos and invalid install paths.

## Module or realm errors

Match the Haxe package to the path below the mirrored root and capitalize named
module filenames (`player/PlayerVar.hx`, `package player; class PlayerVar`).
Use `#if gmod_server` / `#if gmod_client` around realm-only references in shared
files. Break import cycles by extracting a dependency into a third module.
The build prints the original source and realm even for a staged lowercase loader.
Named modules cache initialization: restart the realm to test edited implementations.

## `hxgmod` is not recognized

Run the SDK's `setup.ps1`, then open a new terminal. To bypass PATH immediately:

```powershell
& 'C:\HaxeToolkit\haxe\lib\HxGLUA\hxgmod.bat' doctor
```

`doctor` prints the SDK and launcher paths. If they differ, remove the stale SDK
from PATH and rerun setup. Registration alone does not add the CLI to PATH.

## Haxelib points to another SDK

Run `hxgmod register` from the SDK you intend to use, then `haxelib path hxgmod`.
The result should include that SDK's `src/`. Haxelib local repositories override
global registration; run `haxelib config` in the project directory to locate one.
The SDK now registers its root, using `haxelib.json` with `classPath: src`.

## The wrong main class builds

The SDK no longer contains application entrypoints in `src/`. A project HXML should
start with `-lib hxgmod` then `-cp src`. Check `-main server.ServerMain` or
`client.ClientMain` and the output paths in your legacy HXML. New filesystem projects do not use HXML.
Custom HXML is respected for ordinary bundles; entity/weapon targets use the standard
SDK flags and `src/` directly. Additional libraries or custom source paths for special
targets are not configurable in this release.

## Entity not in the spawn menu

For filesystem projects, use `hxgmod add entity NAME` and inspect its
`shared.hx`. For legacy projects check `entities` in hxgmod.json. Check `ENT.Type`, a valid `Base`,
and `Spawnable = true` in **both** realm compilations. Build all, install, and restart
the map/game. Look for Lua errors on both server and client. Verify the installed
`lua/entities/CLASS/init.lua` and `cl_init.lua`. Remove obsolete raw definitions for
the same class. Do not register the entity again from autorun or a hook.

Addon autorun filenames now contain the project name. Back up and remove a legacy
installation before reinstalling so old fixed-name autoruns do not run alongside it.

## Stale or incomplete build

Run `hxgmod build --package`. `build server` and `build client` are compile checks;
even running them consecutively does not mark a complete all-realm build. Source,
asset, configuration, HXML or binding changes deliberately invalidate packaging.

## Existing install refused

The old toolchain did not record installation ownership. Move the old `NAME` folder
to a backup location, then install again. Do the same if you manually edited installed
files or moved the source project. Keep your editable source outside the install tree.

## Historical patch migration

The inspected SDK had no Patch 13 entity-target implementation. Its `gmod.ENT` was
a generated structure alias, not an active-global extern. This release replaces that
alias with the extern and makes the original structure available as `gmod.ENTStruct`
(similarly for `SWEPStruct`). Update type annotations using the old structure alias.

Remove `LearningEntity.register()` / registration hooks. Configure the target and
use the example entity `main()`. Old patch scripts and demo entrypoints have been
removed from the production SDK; do not reapply numbered historical patches.

The old `addon_name` config key is still accepted, and the `register-library.bat`,
`unregister-library.bat`, `update-bindings.bat`, and `tools/package_addon.py` entrypoints
delegate to the maintained CLI. Current project names use lowercase portable folder
names. Existing project raw files are preserved; resolve reported collisions explicitly.
