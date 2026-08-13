package modding;

#if cpp
import lime.system.CFFI;
#end

class NativeModding
{
	public static var version(default, null):String = "0.0.1";

	var libraryName:String;
	var loaded:Bool;

	public function new(libraryName:String)
	{
		this.libraryName = libraryName;
		this.loaded = false;
	}

	public function load():Bool
	{
		#if cpp
		try
		{
			loaded = CFFI.load(libraryName, "modding_init", 0) != null;
		}
		catch (e:Dynamic)
		{
			loaded = false;
		}
		#else
		loaded = false;
		#end

		return loaded;
	}

	public function call(functionName:String, argCount:Int, args:Array<Dynamic>):Dynamic
	{
		#if cpp
		if (!loaded)
			return null;

		var prim:Dynamic = CFFI.load(libraryName, functionName, argCount);

		if (prim == null)
			return null;

		return switch (argCount)
		{
			case 0: prim();
			case 1: prim(args[0]);
			case 2: prim(args[0], args[1]);
			case 3: prim(args[0], args[1], args[2]);
			case 4: prim(args[0], args[1], args[2], args[3]);
			default: null;
		}
		#else
		return null;
		#end
	}

	public function unload():Void
	{
		loaded = false;
	}

	public function isLoaded():Bool
	{
		return loaded;
	}

	public static function isSupported():Bool
	{
		#if cpp
		return true;
		#else
		return false;
		#end
	}
}
