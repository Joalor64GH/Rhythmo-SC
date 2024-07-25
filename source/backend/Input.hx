package backend;

import flixel.input.FlxInput.FlxInputState;

class Input {
    public static var actionMap:Map<String, FlxKey> = [
        "left" => SaveData.getData("keyboardBinds")[0],
        "down" => SaveData.getData("keyboardBinds")[1],
        "up" => SaveData.getData("keyboardBinds")[2],
        "right" => SaveData.getData("keyboardBinds")[3],
        "accept" => SaveData.getData("keyboardBinds")[4],
        "exit" => SaveData.getData("keyboardBinds")[5]
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
        "gamepad_left" => SaveData.getData("gamepadBinds")[0],
        "gamepad_down" => SaveData.getData("gamepadBinds")[1],
        "gamepad_up" => SaveData.getData("gamepadBinds")[2],
        "gamepad_right" => SaveData.getData("gamepadBinds")[3],
        "gamepad_accept" => SaveData.getData("gamepadBinds")[4],
        "gamepad_exit" => SaveData.getData("gamepadBinds")[5]
    ];

    public static function gamepadIs(key:String, ?state:FlxInputState = JUST_PRESSED):Bool {
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        if (gamepad != null)
            return (controllerMap.exists(key)) ? gamepad.checkStatus(controllerMap.get(key), state)
                : gamepad.checkStatus(FlxGamepadInputID.fromString(key), state);

        return false;
    }
}