package json;

class JsonScript
{
	public static var version(default, null):String = "0.0.1";

	var scriptPath:String;
	var commands:Array<Dynamic>;
	var variables:Map<String, Dynamic>;
	var handlers:Map<String, Array<Dynamic>->Void>;

	public function new(scriptPath:String)
	{
		this.scriptPath = scriptPath;
		commands = [];
		variables = new Map<String, Dynamic>();
		handlers = new Map<String, Array<Dynamic>->Void>();
	}

	public function load():Bool
	{
		if (!sys.FileSystem.exists(scriptPath))
			return false;

		var content:String = sys.io.File.getContent(scriptPath);

		try
		{
			var data:Dynamic = haxe.Json.parse(content);
			commands = Std.isOfType(data, Array) ? cast data : [];
		}
		catch (e:Dynamic)
		{
			return false;
		}

		return true;
	}

	public function register(action:String, handler:Array<Dynamic>->Void):Void
	{
		handlers.set(action, handler);
	}

	public function set(name:String, value:Dynamic):Void
	{
		variables.set(name, value);
	}

	public function get(name:String):Dynamic
	{
		return variables.get(name);
	}

	public function execute():Void
	{
		for (command in commands)
			runCommand(command);
	}

	function runCommand(command:Dynamic):Void
	{
		var action:String = Reflect.field(command, "action");

		if (action == null)
			return;

		var args:Array<Dynamic> = Reflect.hasField(command, "args") ? Reflect.field(command, "args") : [];

		var handler:Array<Dynamic>->Void = handlers.get(action);

		if (handler != null)
			handler(args);
	}
}
