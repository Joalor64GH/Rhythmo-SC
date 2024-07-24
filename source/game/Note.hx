package game;

class Note extends FlxSprite {
    public var dir:String = ''; // note direction
    public var type:String = ''; // receptor of plain note

    public function new(x:Float, y:Float, dir:String) {
        super(x, y);

        this.dir = dir;
        this.type = type;

        loadGraphic(Paths.image('ui/note_$dir'), 200, 200);

        animation.add("note", [0], 1);
        animation.add("press", [1], 1);
        animation.add("receptor", [2], 1);

        animation.play((type == 'receptor') ? "receptor" : "note");
    }

    public function press() {
        animation.play("press");
    }

    override function update(elapsed:Float) {
        if (type != "receptor")
            y += 200 * elapsed;
        super.update(elapsed);
    }
}
