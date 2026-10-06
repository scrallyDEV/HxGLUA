# Everyday Haxe / GMod recipes

Create an addon with `hxgmod new addon my_addon`, enter it, then
`hxgmod build --package`. A single named server autorun prints a loaded message.
There are no empty helper files or HXML files to maintain.

## Add code

```powershell
hxgmod add autorun welcome --realm server
hxgmod add autorun hud --realm client
hxgmod add autorun shared_setup --realm shared
hxgmod add hook ready
hxgmod add command hello
hxgmod add entity my_addon_prop
hxgmod add swep my_addon_tool
hxgmod build --package
```

`add` never overwrites existing files. Script names become project-prefixed Haxe
class names with matching packages. Scripts default to server. Hooks start with
an `Initialize` callback; commands start with a console-print callback. Edit the
event/callback for your task. Add permission checks before implementing privileged
console actions. `add script` is the general script form; in addons it is an autorun.

Entities use the supplied name verbatim. SWEPs receive `weapon_` if omitted.
Both generate `init.hx`, `cl_init.hx`, and `shared.hx`, with minimal active
`gmod.ENT` / `gmod.SWEP` definitions. The entity is a physics barrel; the SWEP is
a training tool with no attacks. The lowercase GMod loader files deliberately use
`package; class Main`: each invocation must configure the current ENT/SWEP table.
Ordinary reusable modules use normal named Haxe classes.

## Server autorun and hooks

```haxe
// src/lua/autorun/server/Welcome.hx
package autorun.server;
class Welcome {
    public static function main():Void {
        gmod.Hook.add("Initialize", "my_addon_ready", function():Void {
            lua.Lua.print("Ready");
        });
    }
}
```

Use unique names: GMod merges Lua paths, hook IDs and command names across addons.

## Shared helper versus shared module

```haxe
// src/shared/Labels.hx (optional bundled helper)
package shared;
class Labels {
    public static function greeting():String { return "Hello"; }
}
```

Import `shared.Labels` normally. This is optional Haxe helper space, not a GMod
directory, and `shared/` does not imply networked state. To share one mutable
instance across generated files **within a realm**, put a named module inside
the mirrored tree:

```haxe
// src/lua/my_addon/Counter.hx
package my_addon;
class Counter {
    public static var calls:Int = 0;
    public static function next():Int { return ++calls; }
}
```

```haxe
// src/lua/autorun/server/Count.hx
package autorun.server;
import my_addon.Counter;
class Count {
    public static function main():Void { lua.Lua.print(Counter.next()); }
}
```

`Counter.lua` is loaded automatically by `Count.lua`. It is not copied into it.
Server and client are separate Lua states; use normal GMod networking between them.
See [filesystem sources](filesystem.md) for module restrictions and realm guards.

## Gamemodes

```powershell
hxgmod new gamemode my_mode --title "My Mode" --base sandbox
cd my_mode
hxgmod add entity my_mode_prop
hxgmod add script welcome --realm server
```

Gamemode loaders live in `src/gamemode-root/gamemode/`. Entities and weapons live
in `src/gamemode-root/entities/entities/` and `entities/weapons/`, respectively.
`add script`, `add hook` and `add command` print an include line to place in the
matching gamemode loader. They do not silently edit your loader. `autorun` is an
addon convention; gamemodes use `init.hx`/`cl_init.hx` and explicit includes.

## Config defaults

A new addon needs only:

```json
{"name": "my_addon", "project_type": "addon", "source_layout": "filesystem"}
```

`project_type` defaults to `addon`. `install_path` is optional and may be relative
to the project root. Gamemode title/base/category/maps are optional (defaults:
project name, sandbox, other, no map filter). JSON does not allow comments.
Keep `source_layout` explicit: omission intentionally selects the legacy layout
so existing projects continue to compile. `addon_name` remains a supported old
spelling for `name`; no automatic config rewrite occurs.

All project commands search the current directory and parents. From elsewhere,
use `hxgmod --project "PATH/my addon/src" build --package`. For compiler details,
use `hxgmod --verbose build`. No Java, hxjava or JDK is needed for this Lua target.
