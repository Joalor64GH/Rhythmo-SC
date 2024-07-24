package backend;

class SaveData {
	static public var defaultOptions:Array<Array<Dynamic>> = [
		// name, value
		["lang", 'en'],
		["fpsCounter", true],
		#if desktop
		["fullscreen", false],
		#end
		["framerate", 60]
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