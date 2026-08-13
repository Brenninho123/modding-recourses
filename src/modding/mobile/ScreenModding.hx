package modding.mobile;

import lime.app.Application;
import lime.ui.Window;
import lime.system.System;

class ScreenModding
{
	public static var version(default, null):String = "0.0.1";

	public static function setResolution(width:Int, height:Int):Void
	{
		var window:Window = Application.current.window;

		if (window == null)
			return;

		window.resize(width, height);
	}

	public static function getResolution():{width:Int, height:Int}
	{
		var window:Window = Application.current.window;

		if (window == null)
			return {width: 0, height: 0};

		return {width: window.width, height: window.height};
	}

	public static function getSafeArea():{left:Float, top:Float, right:Float, bottom:Float}
	{
		#if ios
		return {
			left: System.getValue("safeAreaLeft"),
			top: System.getValue("safeAreaTop"),
			right: System.getValue("safeAreaRight"),
			bottom: System.getValue("safeAreaBottom")
		};
		#else
		return {left: 0, top: 0, right: 0, bottom: 0};
		#end
	}

	public static function setOrientation(orientation:String):Void
	{
		var window:Window = Application.current.window;

		if (window == null)
			return;

		switch (orientation)
		{
			case "portrait":
				window.__backend.setOrientation("portrait");
			case "landscape":
				window.__backend.setOrientation("landscape");
			default:
		}
	}

	public static function getOrientation():String
	{
		var window:Window = Application.current.window;

		if (window == null)
			return "unknown";

		return window.width >= window.height ? "landscape" : "portrait";
	}
}
