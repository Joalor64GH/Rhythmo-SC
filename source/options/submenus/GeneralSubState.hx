package options.submenus;

import options.Option;

class GeneralSubState extends OptionsSubState {
    public function new() {
        super();

        var option:Option = new Option("Framerate", 
            "Use LEFT/RIGHT to change the framerate (Max 240).", 
            OptionType.Integer(60, 240, 10), 
            SaveData.settings.framerate
        );
        option.onChange = (value:Dynamic) -> {
            Main.updateFramerate(value);
        };
        options.push(option);

        var option:Option = new Option("FPS Counter", 
            "Toggles the FPS Display.", 
            OptionType.Toggle, 
            SaveData.settings.fpsCounter
        );
        option.onChange = (value:Dynamic) -> {
            if (Main.fpsDisplay != null)
				Main.fpsDisplay.visible = value;
        };
        options.push(option);
    }
}