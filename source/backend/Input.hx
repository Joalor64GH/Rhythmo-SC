package backend;

import flixel.input.FlxInput.FlxInputState;

class Input {
    public static var actionMap:Map<String, FlxKey> = [
        "left" => LEFT,
        "down" => DOWN,
        "up" => UP,
        "right" => RIGHT,
        "accept" => ENTER,
        "exit" => ESCAPE
    ];

    public static function is(action:String, ?state:FlxInputState = JUST_PRESSED, ?exact:Bool = false):Bool {
        if (!exact) {
            if (state == PRESSED && is(action, JUST_PRESSED))
                return true;
            if (state == RELEASED && is(action, JUST_RELEASED))
                return true;
        }
        
        return (actionMap.exists(action)) ? FlxG.keys.checkStatus(actionMap.get(action), state) 
            : FlxG.keys.checkStatus(FlxKey.fromString(action), state);
    }

    public static function get(action:String):FlxInputState {
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        
        if (gamepad != null) {
            if (gamepadIs(action, JUST_PRESSED))
                return JUST_PRESSED;
            if (gamepadIs(action, PRESSED))
                return PRESSED;
            if (gamepadIs(action, JUST_RELEASED))
                return JUST_RELEASED;
        } else {
            if (is(action, JUST_PRESSED))
                return JUST_PRESSED;
            if (is(action, PRESSED))
                return PRESSED;
            if (is(action, JUST_RELEASED))
                return JUST_RELEASED;
        }
        
        return RELEASED;
    }

    public static var controllerMap:Map<String, FlxGamepadInputID> = [
        "gamepad_left" => DPAD_LEFT,
        "gamepad_down" => DPAD_DOWN,
        "gamepad_up" => DPAD_UP,
        "gamepad_right" => DPAD_RIGHT,
        "gamepad_accept" => A,
        "gamepad_exit" => B
    ];

    public static function gamepadIs(key:String, ?state:FlxInputState = JUST_PRESSED):Bool {
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        if (gamepad != null)
            return (controllerMap.exists(key)) ? gamepad.checkStatus(controllerMap.get(key), state)
                : gamepad.checkStatus(FlxGamepadInputID.fromString(key), state);

        return false;
    }
}