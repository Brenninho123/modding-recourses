package modding;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

class HModdingInterp extends Interp
{
	public var classes:Map<String, Dynamic>;

	public function new()
	{
		super();
		classes = new Map<String, Dynamic>();
	}

	override function resolve(id:String):Dynamic
	{
		if (classes.exists(id))
			return classes.get(id);

		return super.resolve(id);
	}
}

class HModding
{
	public static var version(default, null):String = "0.0.1";

	var parser:Parser;
	var interp:HModdingInterp;
	var scriptPath:String;
	var program:Expr;
	var imports:Map<String, Dynamic>;

	public function new(scriptPath:String)
	{
		this.scriptPath = scriptPath;
		parser = new Parser();
		parser.allowJSON = true;
		parser.allowTypes = true;
		parser.allowMetadata = true;

		interp = new HModdingInterp();
		imports = new Map<String, Dynamic>();

		registerDefaults();
	}

	function registerDefaults():Void
	{
		importClass("Math", Math);
		importClass("Std", Std);
		importClass("StringTools", StringTools);
		importClass("Reflect", Reflect);
		importClass("Type", Type);
	}

	public function importClass(name:String, value:Dynamic):Void
	{
		imports.set(name, value);
		interp.classes.set(name, value);
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

	public function exists(name:String):Bool
	{
		return interp.variables.exists(name);
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

	public function reload():Bool
	{
		interp = new HModdingInterp();

		for (name => value in imports)
			interp.classes.set(name, value);

		return load();
	}
}
