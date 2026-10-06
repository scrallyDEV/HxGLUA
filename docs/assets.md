# Models, materials and other assets

Place **already GMod-compatible** files beside `hxgmod.json`. No asset list or
conversion step is required. Create only the folders you need.

```text
my_addon/
  hxgmod.json
  src/lua/...
  models/my_addon/prop.mdl
  models/my_addon/prop.vvd
  models/my_addon/prop.dx90.vtx
  models/my_addon/prop.phy       # if supplied by the model author
  materials/models/my_addon/prop.vmt
  materials/models/my_addon/prop.vtf
```

Copy the model author's complete `models/` and `materials/` trees, retaining
their names and subfolders. Include any supplied `.ani`, `.vtx` variants and other
companions. HxGMod copies every file; you do not enumerate companions. It does not
inspect model binaries, convert formats, or repair missing textures. Do not rename
material directories referenced inside an existing model.

Run `hxgmod build --package`, then `hxgmod install "PATH/garrysmod"` (or use
`hxgmod build --install "PATH/garrysmod"` in one step).

| Project folder | Addon output | Gamemode output |
| --- | --- | --- |
| `models/` | `models/` | `content/models/` |
| `materials/` | `materials/` | `content/materials/` |
| `sound/` | `sound/` | `content/sound/` |
| `resource/` | `resource/` | `content/resource/` |
| `particles/` | `particles/` | `content/particles/` |
| `maps/` | `maps/` | `content/maps/` |

The output is under `dist/NAME/`. Source asset folders are identical for addons
and gamemodes. `package-root/` remains an escape hatch copied verbatim into the
package root; old projects need no migration. For gamemode assets there, use
`package-root/content/models/`, etc. Never put the same destination in both trees.

Use normal engine paths in Haxe:

```haxe
// In an entity's server-side Initialize callback:
self.setModel("models/my_addon/prop.mdl");
self.setMaterial("models/my_addon/paint"); // materials/models/my_addon/paint.vmt
```

Model paths include `models/` and `.mdl`. Material names used by `setMaterial`
omit `materials/` and `.vmt`. A model material should use `VertexLitGeneric`.
See [Entity:SetMaterial](https://wiki.facepunch.com/gmod/Entity:SetMaterial).
`examples/hx_learning/materials/hx_learning/blue.vmt` is a tiny original example
using an engine texture; no third-party model download is required.

## Multiplayer downloads

Packaging installs files on the machine receiving the package. Joining clients
also need those assets. Keep normal GMod download configuration; HxGMod does not
publish or configure a download server. In a **server** autorun (or gamemode init):

```haxe
gmod.ResourceLib.addFile("models/my_addon/prop.mdl");
gmod.ResourceLib.addFile("materials/models/my_addon/prop.vmt");
```

[resource.AddFile](https://wiki.facepunch.com/gmod/resource.AddFile) adds known
model companions and a same-named VTF for a VMT. Add differently named textures
and other dependencies separately, and configure the server's normal download
delivery. Packaging includes all files but does not infer download dependencies.

## Freshness and safety

Asset edits, additions and deletions invalidate the build stamp. Run
`hxgmod build --package` again; `package` alone reports a stale build.
Successful packaging replaces the previous package, removing deleted assets.
`clean` removes generated `build/` and `dist/`, retaining your source assets.
Never keep editable originals in those generated folders.

Duplicate destinations, case-only collisions, file-versus-folder collisions,
reserved install metadata and nonportable filenames fail with a path in the error.
Symlinks/junctions are rejected. Project paths and asset filenames with spaces are
supported; preserve the asset author's paths and prefer lowercase names for new
assets so Linux servers agree with Windows.

`data/` is GMod runtime storage and is not an automatic package input. Ship
read-only defaults in an appropriate resource path and create writable data at
runtime. `sounds/` is a common typo: the folder is `sound/`. Run `hxgmod doctor`
to catch these misplaced folders.
