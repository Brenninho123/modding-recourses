package modding;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

class HaxeModding
{
	public static var version(default, null):String = "0.0.1";

	var parser:Parser;
	var interp:Interp;
	var scriptPath:String;
	var program:Expr;

	public function new(scriptPath:String)
	{
		this.scriptPath = scriptPath;
		parser = new Parser();
		interp = new Interp();
	}

	public function load():Bool
	{
		if (!sys.FileSystem.exists(scriptPath))
			return false;

		var content:String = sys.io.File.getContent(scriptPath);

		try
		{
			program = parser.parseString(content, scriptPath);
		}
		catch (e:Dynamic)
		{
			return false;
		}

		return true;
	}

	public function set(name:String, value:Dynamic):Void
	{
		interp.variables.set(name, value);
	}

	public function get(name:String):Dynamic
	{
		return interp.variables.get(name);
	}

	public function call(name:String, args:Array<Dynamic>):Dynamic
	{
		var fn:Dynamic = interp.variables.get(name);

		if (fn == null)
			return null;

		return Reflect.callMethod(null, fn, args);
	}

	public function execute():Dynamic
	{
		if (program == null)
			return null;

		return interp.execute(program);
	}
}
