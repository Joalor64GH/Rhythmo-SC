package game;

class Checker extends GameSprite {
	public var checked:Bool = true;
	public var sprTracker:FlxSprite;

	public function new(x:Float = 0, y:Float = 0, checked:Bool = true) {
		super(x, y);

		this.checked = checked;

		loadGraphic(Paths.image('menu/checker'), true, 400, 400);
		setGraphicSize(65, 65);
		scrollFactor.set();
		updateHitbox();

		animation.add("check", [0], 1);
		animation.add("uncheck", [1], 1);
		animation.play((checked) ? "check" : "uncheck");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y);
	}
}