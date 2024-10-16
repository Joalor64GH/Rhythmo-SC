package options.submenus;

import options.Option;

class GeneralSubState extends OptionsSubState {
    public function new() {
        super();

        var option:Option = new Option("Framerate", 
            "Use LEFT/RIGHT to change the framerate (Max 240).", 
            Option.Integer(60, 240, 10), 
            SaveData.settings.framerate
        );
        option.onChange = () -> {
            Main.updateFramerate(SaveData.settings.framerate);
        };
        options.push(option);

        var option:Option = new Option("FPS Counter", 
            "Toggles the FPS Display.", 
            Option.Toggle, 
            SaveData.settings.fpsCounter
        );
        option.onChange = () -> {
            if (Main.fpsDisplay != null)
				Main.fpsDisplay.visible = SaveData.settings.fpsCounter;
        };
        options.push(option);
    }
}