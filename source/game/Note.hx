package game;

class Note extends FlxSprite {
    public var dir:String = ''; // note direction
    public function new(x:Float, y:Float, dir:String) {
        super(x, y);
        this.dir = dir;

        loadGraphic(Paths.image('ui/note_$dir'), 200, 200);

        animation.add("note", [0], 1);
        animation.add("press", [1], 1);
        animation.add("receptor", [2], 1);
    }
}