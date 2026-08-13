package mod;

import modding.HaxeModding;

class ModStuff
{
	public static var version(default, null):String = "0.0.1";

	public static var supportedExtensions(default, null):Array<String> = ["hx", "hxs"];

	var scripts:Map<String, HaxeModding>;

	public function new()
	{
		scripts = new Map<String, HaxeModding>();
	}

	public static function isSupported(path:String):Bool
	{
		var extension:String = haxe.io.Path.extension(path).toLowerCase();
		return supportedExtensions.indexOf(extension) != -1;
	}

	public function loadFolder(folder:String):Void
	{
		if (!sys.FileSystem.exists(folder))
			return;

		for (entry in sys.FileSystem.readDirectory(folder))
		{
			var entryPath:String = haxe.io.Path.join([folder, entry]);

			if (sys.FileSystem.isDirectory(entryPath))
				continue;

			if (!isSupported(entryPath))
				continue;

			loadScript(entryPath);
		}
	}

	public function loadScript(path:String):Bool
	{
		if (!isSupported(path))
			return false;

		var script:HaxeModding = new HaxeModding(path);

		if (!script.load())
			return false;

		scripts.set(path, script);

		return true;
	}

	public function unloadScript(path:String):Void
	{
		scripts.remove(path);
	}

	public function get(path:String):HaxeModding
	{
		return scripts.get(path);
	}

	public function executeAll():Void
	{
		for (script in scripts)
			script.execute();
	}

	public function callAll(name:String, args:Array<Dynamic>):Array<Dynamic>
	{
		var results:Array<Dynamic> = [];

		for (script in scripts)
			results.push(script.call(name, args));

		return results;
	}

	public function setAll(name:String, value:Dynamic):Void
	{
		for (script in scripts)
			script.set(name, value);
	}

	public function list():Array<String>
	{
		var result:Array<String> = [];

		for (path in scripts.keys())
			result.push(path);

		return result;
	}
}
