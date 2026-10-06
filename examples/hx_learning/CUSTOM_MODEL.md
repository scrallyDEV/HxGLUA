# Try your own model

This example uses the stock oil drum, so it works without external downloads.
No placeholder binary is passed off as a real model. To try an asset you may use:

1. Copy its complete model and material folders into this project:
   `models/hx_learning/prop.mdl`, `.vvd`, `.dx90.vtx`, optional `.phy` and any
   other supplied companions; retain the material folders referenced by the model.
2. In `src/lua/entities/hx_learning_prop/shared.hx`, change `self.setModel(...)`
   to `self.setModel("models/hx_learning/prop.mdl")`. Prefer the model author's
   actual relative name if different. A physics prop needs compatible physics data.
3. Run `hxgmod build --package`, then install. No copying into dist is needed.
4. For multiplayer, add the model and material paths with
   `gmod.ResourceLib.addFile(...)` in a server script and configure normal GMod
   content downloads. See the SDK's `docs/assets.md`.

The bundled original `materials/hx_learning/blue.vmt` uses an existing engine
texture and is applied to the example barrel. You may reuse or modify that tiny
material freely. Removing the material override lets an imported model display
its own materials.
