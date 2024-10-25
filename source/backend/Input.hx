package backend;

typedef Bind = {
	key:Array<FlxKey>,
	gamepad:Array<FlxGamepadInputID>
}

class Input {
	public static var binds:Map<String, Bind> = [
		'left' => {key: [LEFT, A], gamepad: [DPAD_LEFT, LEFT_TRIGGER]},
		'down' => {key: [DOWN, S], gamepad: [DPAD_DOWN, LEFT_SHOULDER]},
		'up' => {key: [UP, W], gamepad: [DPAD_UP, RIGHT_SHOULDER]},
		'right' => {key: [RIGHT, D], gamepad: [DPAD_RIGHT, RIGHT_TRIGGER]},
		'accept' => {key: [ENTER], gamepad: [A, START]},
		'exit' => {key: [ESCAPE], gamepad: [B, BACK]},
		'reset' => {key: [R], gamepad: [RIGHT_STICK_CLICK]}
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