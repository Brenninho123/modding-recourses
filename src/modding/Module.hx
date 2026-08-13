package modding;

import modding.HaxeModding;
import json.JsonScript;

typedef ModuleManifest =
{
	id:String,
	name:String,
	version:String,
	main:String,
	?type:String,
	?dependencies:Array<String>
}

class Module
{
	public var id(default, null):String;
	public var name(default, null):String;
	public var version(default, null):String;
	public var path(default, null):String;
	public var dependencies(default, null):Array<String>;
	public var enabled(default, null):Bool;

	var hscriptInstance:HaxeModding;
	var jsonInstance:JsonScript;
	var scriptType:String;

	public function new(manifest:ModuleManifest, path:String)
	{
		this.id = manifest.id;
		this.name = manifest.name;
		this.version = manifest.version;
		this.path = path;
		this.dependencies = manifest.dependencies != null ? manifest.dependencies : [];
		this.scriptType = manifest.type != null ? manifest.type : "hscript";
		this.enabled = false;

		var mainPath:String = haxe.io.Path.join([path, manifest.main]);

		if (scriptType == "json")
			jsonInstance = new JsonScript(mainPath);
		else
			hscriptInstance = new HaxeModding(mainPath);
	}

	public function load():Bool
	{
		return scriptType == "json" ? jsonInstance.load() : hscriptInstance.load();
	}

	public function enable():Void
	{
		enabled = true;

		if (scriptType == "hscript")
			hscriptInstance.execute();
	}

	public function disable():Void
	{
		enabled = false;
	}

	public function call(name:String, args:Array<Dynamic>):Dynamic
	{
		if (!enabled)
			return null;

		if (scriptType == "hscript")
			return hscriptInstance.call(name, args);

		return null;
	}

	public function set(name:String, value:Dynamic):Void
	{
		if (scriptType == "hscript")
			hscriptInstance.set(name, value);
		else
			jsonInstance.set(name, value);
	}

	public function registerAction(action:String, handler:Array<Dynamic>->Void):Void
	{
		if (scriptType == "json")
			jsonInstance.register(action, handler);
	}

	public function runJson():Void
	{
		if (scriptType == "json")
			jsonInstance.execute();
	}
}

class ModuleManager
{
	public static var version(default, null):String = "0.0.1";

	var modules:Map<String, Module>;

	public function new()
	{
		modules = new Map<String, Module>();
	}

	public function loadFromFolder(folder:String):Void
	{
		if (!sys.FileSystem.exists(folder))
			return;

		for (entry in sys.FileSystem.readDirectory(folder))
		{
			var entryPath:String = haxe.io.Path.join([folder, entry]);

			if (!sys.FileSystem.isDirectory(entryPath))
				continue;

			var manifestPath:String = haxe.io.Path.join([entryPath, "module.json"]);

			if (!sys.FileSystem.exists(manifestPath))
				continue;

			var manifest:ModuleManifest = haxe.Json.parse(sys.io.File.getContent(manifestPath));
			var module:Module = new Module(manifest, entryPath);

			if (module.load())
				modules.set(module.id, module);
		}
	}

	public function get(id:String):Module
	{
		return modules.get(id);
	}

	public function enableAll():Void
	{
		for (module in modules)
			if (resolveDependencies(module))
				module.enable();
	}

	public function disableAll():Void
	{
		for (module in modules)
			module.disable();
	}

	public function call(name:String, args:Array<Dynamic>):Void
	{
		for (module in modules)
			if (module.enabled)
				module.call(name, args);
	}

	function resolveDependencies(module:Module):Bool
	{
		for (dependency in module.dependencies)
		{
			var dependencyModule:Module = modules.get(dependency);

			if (dependencyModule == null)
				return false;
		}

		return true;
	}

	public function list():Array<Module>
	{
		var result:Array<Module> = [];

		for (module in modules)
			result.push(module);

		return result;
	}
}
