# Release notes

## Unreleased — 1.0 readiness pass (package version remains 0.3.0)

- Minimal addon starter with an ordinary named server autorun; no empty shared
  helper. Conventional gamemode loaders retained.
- Automatic models/materials/sound/resource/particles/maps packaging, including
  all model companions and gamemode content destinations. Existing package-root
  behavior retained. Asset changes invalidate packaging and stale files disappear
  after a successful rebuild/package.
- `add autorun|script|hook|command|entity|swep`, with realm selection for scripts,
  non-overwrite checks and templates using existing public bindings.
- `--project` and `--verbose`; concise build output identifies source and realm.
  CLI version is read from haxelib metadata, avoiding separate version drift.
- Portable path validation and collision checks shared by asset packaging paths;
  doctor checks common misplaced asset folders and configured install locations.
- Practical asset, quickstart and troubleshooting docs; expanded hx_learning.

No compiler/linker redesign, public binding regeneration, external publication,
model conversion, Workshop integration or Java dependency. Existing filesystem and
legacy configs remain supported. New automatic asset folders can expose collisions
in projects that already have the same files in package-root: keep only one copy.
New scaffold filenames differ; existing projects are never rewritten.

Release gate: verify loaders, spawn menus, physics, materials, gamemode content
mounting and multiplayer asset downloads inside Garry's Mod before tagging 1.0.
