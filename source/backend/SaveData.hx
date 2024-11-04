package backend;

@:structInit class SaveSettings {
	public var lang:String = 'en';
	public var hitSoundType:String = 'Default';
	public var framerate:Int = 60;
	public var songSpeed:Int = 2;
	public var hitSoundVolume:Int = 0;
	public var laneUnderlay:Int = 0;
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
	public var notesRGB:Array<Array<Int>> = [[221, 0, 255], [0, 128, 255], [0, 215, 54], [255, 0, 106]];
	public var keyboardBinds:Array<FlxKey> = [LEFT, DOWN, UP, RIGHT, A, S, W, D, ENTER, ESCAPE, R];
	public var gamepadBinds:Array<FlxGamepadInputID> = [
		DPAD_LEFT, DPAD_DOWN, DPAD_UP, DPAD_RIGHT, LEFT_TRIGGER, LEFT_SHOULDER, RIGHT_SHOULDER, RIGHT_TRIGGER, A, B, RIGHT_STICK_CLICK
	];
}

class SaveData {
	public static var settings:SaveSettings = {};

	public static function init() {
		for (key in Reflect.fields(settings))
			if (Reflect.field(FlxG.save.data, key) != null)
				Reflect.setField(settings, key, Reflect.field(FlxG.save.data, key));

		if (Main.fpsDisplay != null)
			Main.fpsDisplay.visible = settings.fpsCounter;

		if (FlxG.save.data.framerate == null) {
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			settings.framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
		}

		Main.updateFramerate(settings.framerate);
		Input.refreshControls();
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