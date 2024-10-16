package options.submenus;

import options.Option;

class AppearanceSubState extends OptionsSubState {
    public function new() {
        super();

        var option:Option = new Option("Antialising", 
            "If disabled, improves the game's performance at the cost of sharper visuals.", 
            OptionType.Toggle, 
            SaveData.settings.antialiasing
        );
        addOption(option);

        #if desktop
        var option:Option = new Option("Fullscreen", 
            "Toggles fullscreen", 
            OptionType.Toggle, 
            SaveData.settings.fullscreen
        );
        option.onChange = (value:Dynamic) -> {
            FlxG.fullscreen = value;
        };
        addOption(option);
        #end

        var option:Option = new Option("Flashing Lights", 
            "Turn this off if you're photosensitive.", 
            OptionType.Toggle, 
            SaveData.settings.flashing
        );
        addOption(option);
    }
}