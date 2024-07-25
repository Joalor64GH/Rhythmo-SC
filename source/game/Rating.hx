package game;

class Rating extends GameSprite {
	public function new(x:Float, y:Float) {
		super(x, y);
	}

	public function showCurrentRating() {
		var rating:String = PlayState.instance.curRating;

		scale.set(1.2, 1.2);
		alpha = 1;
		FlxTween.cancelTweensOf(this);

		FlxTween.tween(this, {alpha: 0}, 0.6, {
			ease: FlxEase.cubeInOut,
			startDelay: 1
		});

		loadGraphic(Paths.image('ui/$rating'));
		centerOffsets();
		centerOrigin();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var scaleX:Float = FlxMath.lerp(scale.x, 1, elapsed * 7);
		var scaleY:Float = FlxMath.lerp(scale.x, 1, elapsed * 7);

		scale.set(scaleX, scaleY);
	}
}