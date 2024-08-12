package game;

class AbsoluteSprite extends FlxSprite {
	public var parent:FlxObject;

	public var offsetX:Null<Float> = null;
	public var offsetY:Null<Float> = null;

	public function new(image:String, ?parent:FlxObject, ?offsetX:Float, ?offsetY:Float) {
		super();

		this.parent = parent;
		this.offsetX = offsetX;
		this.offsetY = offsetY;

		loadGraphic(Paths.image(image), false);

		scrollFactor.set();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (parent != null)
			setPosition(parent.x + offsetX, parent.y + offsetY);
	}
}
