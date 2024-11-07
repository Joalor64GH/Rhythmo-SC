package backend;

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

	public static function justPressed(tag:String):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (binds.exists(tag)) {
				for (i in 0...binds[tag].gamepad.length)
					if (gamepad.checkStatus(binds[tag].gamepad[i], JUST_PRESSED))
						return true;
			} else {
				return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), JUST_PRESSED);
			}
		} else {
			if (binds.exists(tag)) {
				for (i in 0...binds[tag].key.length)
					if (FlxG.keys.checkStatus(binds[tag].key[i], JUST_PRESSED))
						return true;
			} else {
				return FlxG.keys.checkStatus(FlxKey.fromString(tag), JUST_PRESSED);
			}
		}

		return false;
	}

	public static function pressed(tag:String):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (binds.exists(tag)) {
				for (i in 0...binds[tag].gamepad.length)
					if (gamepad.checkStatus(binds[tag].gamepad[i], PRESSED))
						return true;
			} else {
				return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), PRESSED);
			}
		} else {
			if (binds.exists(tag)) {
				for (i in 0...binds[tag].key.length)
					if (FlxG.keys.checkStatus(binds[tag].key[i], PRESSED))
						return true;
			} else {
				return FlxG.keys.checkStatus(FlxKey.fromString(tag), PRESSED);
			}
		}

		return false;
	}

	public static function justReleased(tag:String):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (binds.exists(tag)) {
				for (i in 0...binds[tag].gamepad.length)
					if (gamepad.checkStatus(binds[tag].gamepad[i], JUST_RELEASED))
						return true;
			} else {
				return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), JUST_RELEASED);
			}
		} else {
			if (binds.exists(tag)) {
				for (i in 0...binds[tag].key.length)
					if (FlxG.keys.checkStatus(binds[tag].key[i], JUST_RELEASED))
						return true;
			} else {
				return FlxG.keys.checkStatus(FlxKey.fromString(tag), JUST_RELEASED);
			}
		}

		return false;
	}

	public static function anyJustPressed(tags:Array<String>):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		for (tag in tags) {
			if (gamepad != null) {
				if (binds.exists(tag)) {
					for (i in 0...binds[tag].gamepad.length)
						if (gamepad.checkStatus(binds[tag].gamepad[i], JUST_PRESSED))
							return true;
				} else {
					return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), JUST_PRESSED);
				}
			} else {
				if (binds.exists(tag)) {
					for (i in 0...binds[tag].key.length)
						if (FlxG.keys.checkStatus(binds[tag].key[i], JUST_PRESSED))
							return true;
				} else {
					return FlxG.keys.checkStatus(FlxKey.fromString(tag), JUST_PRESSED);
				}
			}
		}

		return false;
	}

	public static function anyPressed(tags:Array<String>):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		for (tag in tags) {
			if (gamepad != null) {
				if (binds.exists(tag)) {
					for (i in 0...binds[tag].gamepad.length)
						if (gamepad.checkStatus(binds[tag].gamepad[i], PRESSED))
							return true;
				} else {
					return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), PRESSED);
				}
			} else {
				if (binds.exists(tag)) {
					for (i in 0...binds[tag].key.length)
						if (FlxG.keys.checkStatus(binds[tag].key[i], PRESSED))
							return true;
				} else {
					return FlxG.keys.checkStatus(FlxKey.fromString(tag), PRESSED);
				}
			}
		}

		return false;
	}

	public static function anyJustReleased(tags:Array<String>):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		for (tag in tags) {
			if (gamepad != null) {
				if (binds.exists(tag)) {
					for (i in 0...binds[tag].gamepad.length)
						if (gamepad.checkStatus(binds[tag].gamepad[i], JUST_RELEASED))
							return true;
				} else {
					return gamepad.checkStatus(FlxGamepadInputID.fromString(tag), JUST_RELEASED);
				}
			} else {
				if (binds.exists(tag)) {
					for (i in 0...binds[tag].key.length)
						if (FlxG.keys.checkStatus(binds[tag].key[i], JUST_RELEASED))
							return true;
				} else {
					return FlxG.keys.checkStatus(FlxKey.fromString(tag), JUST_RELEASED);
				}
			}
		}

		return false;
	}
}