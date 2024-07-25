package game;

class Note extends GameSprite {
    public var dir:String = ''; // note direction
    public var type:String = ''; // receptor or plain note

    public function new(x:Float, y:Float, dir:String, type:String) {
        super(x, y);

        this.dir = dir;
        this.type = type;

        loadGraphic(Paths.image('ui/note_$dir'), true, 200, 200);

        animation.add("note", [0], 1);
        animation.add("press", [1], 1);
        animation.add("receptor", [2], 1);

        animation.play((type == 'receptor') ? "receptor" : "note");
    }

    public function press() {
        animation.play("press");
    }
}