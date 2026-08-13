package modding;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

class HaxeModding
{
	public static var version(default, null):String = "0.0.2";

	var parser:Parser;
	var interp:Interp;
	var scriptPath:String;
	var program:Expr;
	var imports:Map<String, Dynamic>;
	var lastError:String;

	public function new(scriptPath:String)
	{
		this.scriptPath = scriptPath;
		parser = new Parser();
		interp = new Interp();
		imports = new Map<String, Dynamic>();
		lastError = null;
	}

	public function importClass(name:String, value:Dynamic):Void
	{
		imports.set(name, value);
		interp.variables.set(name, value);
	}

	public function load():Bool
	{
		lastError = null;

		if (!sys.FileSystem.exists(scriptPath))
		{
			lastError = "Script not found: " + scriptPath;
			return false;
		}

		var content:String = sys.io.File.getContent(scriptPath);

		try
		{
			program = parser.parseString(content, scriptPath);
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			return false;
		}

		return true;
	}

	public function reload():Bool
	{
		interp = new Interp();

		for (name => value in imports)
			interp.variables.set(name, value);

		return load();
	}

	public function unload():Void
	{
		program = null;
	}

	public function set(name:String, value:Dynamic):Void
	{
		interp.variables.set(name, value);
	}

	public function get(name:String):Dynamic
	{
		return interp.variables.get(name);
	}

	public function exists(name:String):Bool
	{
		return interp.variables.exists(name);
	}

	public function call(name:String, args:Array<Dynamic>):Dynamic
	{
		var fn:Dynamic = interp.variables.get(name);

		if (fn == null)
			return null;

		try
		{
			return Reflect.callMethod(null, fn, args);
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			return null;
		}
	}

	public function execute():Dynamic
	{
		if (program == null)
			return null;

		try
		{
			return interp.execute(program);
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			return null;
		}
	}

	public function getError():String
	{
		return lastError;
	}

	public function isLoaded():Bool
	{
		return program != null;
	}
}
