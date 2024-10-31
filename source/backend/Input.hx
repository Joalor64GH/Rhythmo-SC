package backend;

typedef Bind = {
	key:Array<FlxKey>,
	gamepad:Array<FlxGamepadInputID>
}

class Input {
	static public var kBinds:Array<Array<FlxKey>> = SaveData.settings.keyboardBinds;
	static public var gBinds:Array<Array<FlxGamepadInputID>> = SaveData.settings.gamepadBinds;
	
	public static var binds:Map<String, Bind> = [
		'left' => {key: [kBinds[0][0], kBinds[0][1]], gamepad: [gBinds[0][0], gBinds[0][1]]},
		'down' => {key: [kBinds[1][0], kBinds[1][1]], gamepad: [gBinds[1][0], gBinds[1][1]]},
		'up' => {key: [kBinds[2][0], kBinds[2][1]], gamepad: [gBinds[2][0], gBinds[2][1]]},
		'right' => {key: [kBinds[3][0], kBinds[3][1]], gamepad: [gBinds[3][0], gBinds[3][1]]},
		'accept' => {key: [kBinds[4][0]], gamepad: [gBinds[4][0], gBinds[4][1]]},
		'exit' => {key: [kBinds[5][0]], gamepad: [gBinds[5][0], gBinds[5][1]]},
		'reset' => {key: [kBinds[6][0]], gamepad: [gBinds[6][0]]}
	];

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