package states;

class OptionState extends FlxState {
    final options:Array<String> = [
        "FPS Counter", 
        "Fullscreen", 
        "Antialiasing", 
        "Framerate", 
        "Controls", 
        "Language"
    ];
    
    override function create() {
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}