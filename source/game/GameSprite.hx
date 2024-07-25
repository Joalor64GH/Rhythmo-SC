package game;

class GameSprite extends FlxSprite {
    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        antialiasing = SaveData.getData("antialiasing");
    }
}