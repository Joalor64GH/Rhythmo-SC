package backend;

class SaveData {
	static public var defaultOptions:Array<Array<Dynamic>> = [
		// name, value
		["lang", 'en'],
		["fpsCounter", true],
		#if desktop
		["fullscreen", false],
		#end
		["antialiasing", true],
		["framerate", 60],
		["keyboardBinds", [LEFT, DOWN, UP, RIGHT, ENTER, ESCAPE]],
		["gamepadBinds", [DPAD_LEFT, DPAD_DOWN, DPAD_UP, DPAD_RIGHT, A, B]]
	];

	static public function init() {
		for (option in defaultOptions)
			if (getData(option[0]) == null)
				saveData(option[0], option[1]);
	}

	static public function saveData(save:String, value:Dynamic) {
		Reflect.setProperty(FlxG.save.data, save, value);
		FlxG.save.flush();
	}

	static public function getData(save:String):Dynamic {
		return Reflect.getProperty(FlxG.save.data, save);
	}

	static public function resetData() {
		FlxG.save.erase();
		init();
	}
}