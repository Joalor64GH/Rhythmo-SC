package backend;

@:structInit class SaveSettings {
	public var lang:String = 'en';
	public var hitSoundType:String = 'Default';
	public var framerate:Int = 60;
	public var songSpeed:Int = 2;
	public var hitSoundVolume:Int = 0;
	public var laneUnderlay:Int = 0;
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
	public var notesRGB:Array<Array<Int>> = [[221, 0, 255], [0, 128, 255], [0, 215, 54], [255, 0, 106]];
	public var keyboardBinds:Array<Array<FlxKey>> = [[LEFT, A], [DOWN, S], [UP, W], [RIGHT, D], [ENTER], [ESCAPE], [R]];
	public var gamepadBinds:Array<Array<FlxGamepadInputID>> = [
		[DPAD_LEFT, LEFT_TRIGGER],
		[DPAD_DOWN, LEFT_SHOULDER],
		[DPAD_UP, RIGHT_SHOULDER],
		[DPAD_RIGHT, RIGHT_TRIGGER],
		[A, START],
		[B, BACK],
		[RIGHT_STICK_CLICK]
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