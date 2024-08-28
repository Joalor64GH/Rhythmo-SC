package backend;

@:structInit class SaveSettings {
	public var lang:String = 'en';
	public var colorFilter = 'NONE';
	public var framerate:Int = 60;
	public var songSpeed:Int = 2;
	public var hitSoundVolume:Float = 0;
	public var underlayAlpha:Float = 0;
	public var antialiasing:Bool = true;
	public var fpsCounter:Bool = true;
	#if desktop
	public var fullscreen:Bool = false;
	#end
	public var downScroll:Bool = false;
	public var botPlay:Bool = false;
	public var flashing:Bool = true;
	public var keyboardBinds:Array<FlxKey> = [LEFT, DOWN, UP, RIGHT, ENTER, ESCAPE, SPACE];
	public var keyboardBindsAlt:Array<FlxKey> = [A, S, W, D];
	public var gamepadBinds:Array<FlxGamepadInputID> = [DPAD_LEFT, DPAD_DOWN, DPAD_UP, DPAD_RIGHT, A, B];
}

class SaveData {
	public static var settings:SaveSettings = {};

	public static function init() {
		for (key in Reflect.fields(settings))
			if (Reflect.field(FlxG.save.data, key) != null)
				Reflect.setField(settings, key, Reflect.field(FlxG.save.data, key));
		
		if (Main.fpsDisplay != null)
			Main.fpsDisplay.visible = settings.fpsCounter;
		
		Main.updateFramerate(settings.framerate);
	}

	public static function saveSettings() {
		for (key in Reflect.fields(settings))
			Reflect.setField(FlxG.save.data, key, Reflect.field(settings, key));

		FlxG.save.flush();

		trace('settings saved!');
	}

	public static function eraseData() {
		FlxG.save.erase();
		init();
	}
}