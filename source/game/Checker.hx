package game;

class Checker extends GameSprite {
    public var checked:Bool = true;
    public function new(x:Float = 0, y:Float = 0, checked:Bool = true) {
        super(x, y);
        this.checked = checked;

        loadGraphic(Paths.image('options/checker'), true, 400, 400);
        scale.set(0.2, 0.2);

        animation.add("check", [0], 1);
        animation.add("uncheck", [1], 1);
        animation.play((checked) ? "check" : "uncheck");
    }
}