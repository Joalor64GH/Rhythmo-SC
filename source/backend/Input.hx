package backend;

import flixel.input.FlxInput.FlxInputState;

typedef Bind = {
	key:Array<FlxKey>,
	gamepad:Array<FlxGamepadInputID>
}

class Input {
	static public var kBinds:Array<FlxKey> = SaveData.settings.keyboardBinds;
	static public var gBinds:Array<FlxGamepadInputID> = SaveData.settings.gamepadBinds;

	public static var binds:Map<String, Bind> = [
		'left' => {key: [kBinds[0], kBinds[4]], gamepad: [gBinds[0], gBinds[4]]},
		'down' => {key: [kBinds[1], kBinds[5]], gamepad: [gBinds[1], gBinds[5]]},
		'up' => {key: [kBinds[2], kBinds[6]], gamepad: [gBinds[2], gBinds[6]]},
		'right' => {key: [kBinds[3], kBinds[7]], gamepad: [gBinds[3], gBinds[7]]},
		'accept' => {key: [kBinds[8]], gamepad: [gBinds[8]]},
		'exit' => {key: [kBinds[9]], gamepad: [gBinds[9]]},
		'reset' => {key: [kBinds[10]], gamepad: [gBinds[10]]}
	];

	public static function refreshControls() {
		binds.clear();
		binds = [
			'left' => {key: [kBinds[0], kBinds[4]], gamepad: [gBinds[0], gBinds[4]]},
			'down' => {key: [kBinds[1], kBinds[5]], gamepad: [gBinds[1], gBinds[5]]},
			'up' => {key: [kBinds[2], kBinds[6]], gamepad: [gBinds[2], gBinds[6]]},
			'right' => {key: [kBinds[3], kBinds[7]], gamepad: [gBinds[3], gBinds[7]]},
			'accept' => {key: [kBinds[8]], gamepad: [gBinds[8]]},
			'exit' => {key: [kBinds[9]], gamepad: [gBinds[9]]},
			'reset' => {key: [kBinds[10]], gamepad: [gBinds[10]]}
		];
	}

	public static function resetControls() {
		kBinds = [LEFT, DOWN, UP, RIGHT, A, S, W, D, ENTER, ESCAPE, R];
		gBinds = [DPAD_LEFT, DPAD_DOWN, DPAD_UP, DPAD_RIGHT, LEFT_TRIGGER, LEFT_SHOULDER, RIGHT_SHOULDER, RIGHT_TRIGGER, A, B, RIGHT_STICK_CLICK];

		SaveData.saveSettings();
		refreshControls();
	}

	public static function justPressed(tag:String):Bool
		return checkInput(tag, JUST_PRESSED);

	public static function pressed(tag:String):Bool
		return checkInput(tag, PRESSED);

	public static function justReleased(tag:String):Bool
		return checkInput(tag, JUST_RELEASED);

	public static function anyJustPressed(tags:Array<String>):Bool
		return checkAnyInputs(tags, JUST_PRESSED);

	public static function anyPressed(tags:Array<String>):Bool
		return checkAnyInputs(tags, PRESSED);

	public static function anyJustReleased(tags:Array<String>):Bool
		return checkAnyInputs(tags, JUST_RELEASED);

	public static function checkInput(tag:String, state:FlxInputState):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (binds.exists(tag)) {
				for (i in binds[tag].gamepad)
					if (i != FlxGamepadInputID.NONE && gamepad.checkStatus(binds[tag].gamepad[i], state))
						return true;
			} else {
				return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), state);
			}
		} else {
			if (binds.exists(tag)) {
				for (i in binds[tag].key)
					if (i != FlxKey.NONE && FlxG.keys.checkStatus(binds[tag].key[i], state))
						return true;
			} else {
				return FlxG.keys.checkStatus(FlxKey.fromString(tag), state);
			}
		}

		return false;
	}

	public static function checkAnyInputs(tags:Array<String>, state:FlxInputState):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		for (tag in tags) {
			if (gamepad != null) {
				if (binds.exists(tag)) {
					for (i in binds[tag].gamepad)
						if (i != FlxGamepadInputID.NONE && gamepad.checkStatus(binds[tag].gamepad[i], state))
							return true;
				} else {
					return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), state);
				}
			} else {
				if (binds.exists(tag)) {
					for (i in binds[tag].key)
						if (i != FlxKey.NONE && FlxG.keys.checkStatus(binds[tag].key[i], state))
							return true;
				} else {
					return FlxG.keys.checkStatus(FlxKey.fromString(tag), state);
				}
			}
		}

		return false;
	}
}