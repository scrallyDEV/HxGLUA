# Bindings and verification

Use clean imports such as `gmod.Player`, `gmod.Hooks`, `gmod.DMG` and
`gmod.TraceResult`. Generated internals stay under `gmod.generated`.

Class names win over secondary types: `Player`, `PlayerEnum`, `PlayerStruct`,
`MaterialEnum`, `ToolStruct`, and `ColorStruct`. The active definition externs
`ENT` / `SWEP` have companion generated aliases `ENTStruct` / `SWEPStruct`.

API input comes from [luttje/glua-api-snippets](https://github.com/luttje/glua-api-snippets)
structured JSON plus Lua annotations for missing APIs. `api/source.json` records
the release and archive hashes. Do not guess which release is installed; inspect it.

```powershell
hxgmod update            # download latest input, generate, type-check, replace
hxgmod update --offline  # use cached API input
```

The update command stages input and generated output. It preserves handwritten
public files byte-for-byte and type-checks the entire `gmod` package, both without
realm restrictions and in strict server/client configurations, before replacing
the library. A download or compiler failure leaves the installed bindings intact.
Rebuild projects afterward. Direct `haxe generator.hxml` is a developer operation
that writes in place; prefer the CLI's checked update route.

Generated aliases are owned only when the first line contains the exact generated
marker. Never put that marker on a handwritten file. Regeneration removes obsolete
generated files and aliases; it does not overwrite handwritten public files.

The generator supports extern inheritance, typed hook callbacks, nullable unions,
native sequences, numeric enum abstracts, overloads, multi-return externs, and realm
guards. The source API is not a guarantee of perfect signatures or realm metadata.
Report incorrect bindings with the relevant Facepunch API page and a small Haxe example.

## Run the offline regression suite

From the SDK:

```powershell
python -m unittest discover -s tests -v
hxgmod update --offline
```

Tests create disposable external projects in paths with spaces and a local haxelib
repository; global registration is untouched. They cover builds, package trees,
raw collisions, failed/partial/stale builds, aliases, strict realm rejection, install
ownership, and cleanup. `python -m pip install lupa` is required for the complete linker/release regression
suite, including real Lua 5.1 and LuaJIT execution. A missing runtime is a test
failure in those suites (some older tests report optional checks as skipped). GMod is not
needed for these tests. Temporary update/test data lives in SDK `.work/`.

## Common imports

| GMod task | Public Haxe API |
| --- | --- |
| Hooks | `gmod.Hook.add` or typed helpers in `gmod.Hooks` |
| Console commands | `gmod.ConcommandLib.add` |
| Entity/SWEP definitions | `gmod.ENT`, `gmod.SWEP` |
| Model/material | `gmod.Entity.setModel`, `setMaterial` |
| Asset downloads (server) | `gmod.ResourceLib.addFile` |
| Include/send Lua | `gmod.LuaScripts.include`, `addCSLuaFile` |

Use editor completion on `gmod.*`. No extra asset wrapper is needed: path strings
are the same ones used by the engine.
