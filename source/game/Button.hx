package game;

// TO-DO: maybe add a color tween??
class Button extends FlxSprite {
    public var clickCallback:Void->Void;

    public function new(x:Float = 0, y:Float = 0, file:String = null, clickCallback:Void->Void) {
        super(x, y);

        this.clickCallback = clickCallback;
        loadGraphic(Paths.image(file));
        scale.set(0.35, 0.35);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed) {
            if (clickCallback != null)
                clickCallback();
        }
    }
}