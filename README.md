# modding-recourses

A Haxe library for adding HScript-based modding support to your game or engine.

## Features

- Load and parse HScript (`.hx`-style) scripts at runtime
- Expose Haxe variables and objects to scripts via `set`
- Read variables and functions back from scripts via `get`
- Call functions defined inside a script directly from Haxe
- Simple per-script instance model, so multiple mods can run in isolation

## Installation

```bash
haxelib git modding-recourses https://github.com/Brenninho123/modding-recourses.git
```

Requires the [`hscript`](https://lib.haxe.org/p/hscript) library:

```bash
haxelib install hscript
```

## Usage

```haxe
import modding.HaxeModding;

var mod = new HaxeModding("mods/example.hx");

if (mod.load())
{
	mod.set("trace", Reflect.makeVarArgs(function(args) trace(args)));

	mod.execute();

	mod.call("onLoad", []);
}
```

### Example script (`mods/example.hx`)

```haxe
function onLoad() {
	trace("Mod loaded!");
}
```

## API

| Method | Description |
| --- | --- |
| `new(scriptPath:String)` | Creates a modding instance bound to a script file |
| `load():Bool` | Reads and parses the script, returns `false` on failure |
| `set(name:String, value:Dynamic):Void` | Exposes a variable/function to the script |
| `get(name:String):Dynamic` | Reads a variable/function from the script |
| `call(name:String, args:Array<Dynamic>):Dynamic` | Calls a function defined in the script |
| `execute():Dynamic` | Runs the parsed script's top-level code |

## Status

Early development. API may change.

## License

Apache-2.0
