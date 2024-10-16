package options.submenus;

import options.Option;

class AppearanceSubState extends OptionsSubState {
    public function new() {
        super();

        var option:Option = new Option("Antialising", 
            "If disabled, improves the game's performance at the cost of sharper visuals.", 
            Option.Toggle, 
            SaveData.settings.antialiasing
        );
        options.push(option);

        #if desktop
        var option:Option = new Option("Fullscreen", 
            "Toggles fullscreen", 
            Option.Toggle, 
            SaveData.settings.fullscreen
        );
        option.onChange = () -> {
            FlxG.fullscreen = SaveData.settings.fullscreen;
        };
        options.push(option);
        #end

        var option:Option = new Option("Flashing Lights", 
            "Turn this off if you're photosensitive.", 
            Option.Toggle, 
            SaveData.settings.flashing
        );
        options.push(option);
    }
}