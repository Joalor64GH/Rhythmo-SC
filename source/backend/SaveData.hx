package backend;

@:structInit class SaveSettings {
	public var lang:String = 'en';
	public var hitSoundType:String = 'Default';
	public var framerate:Int = 60;
	public var songSpeed:Int = 2;
	public var hitSoundVolume:Int = 0;
	public var laneUnderlay:Float = 0;
	public var perfectWindow:Float = 22.5;
	public var niceWindow:Float = 45;
	public var okayWindow:Float = 90;
	public var noWindow:Float = 135;
	public var antialiasing:Bool = true;
	public var fpsCounter:Bool = true;
	#if desktop
	public var fullscreen:Bool = false;
	#end
	public var downScroll:Bool = false;
	public var botPlay:Bool = false;
	public var flashing:Bool = true;
	public var antiMash:Bool = false;
	public var displayMS:Bool = false;
	public var smoothScore:Bool = false;
	public var keyboardBinds:Array<FlxKey> = [LEFT, DOWN, UP, RIGHT, ENTER, ESCAPE, SPACE];
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