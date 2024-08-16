package game;

class NoteSplash extends GameSprite {
    public function setupSplash(x:Float = 0, y:Float = 0, noteData:Int = 0) {
        setPosition(x, y);

        loadGraphic(Paths.image('gameplay/splash_${getDirection(noteData)}'), true, 200, 200);
        scale.set(0.6, 0.6);
        alpha = 0.6;

        animation.add("splash", [0], 1);
        animation.play("splash");
    }

    override function update(elapsed:Float) {
		if (animation.curAnim != null && animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}

    override function kill() {
        alive = false;
        FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.22, {
            ease: FlxEase.circOut, onComplete: (_) -> {
                exists = false;
            }
        });
    }

    function getDirection(index:Int):String {
		return switch (index) {
			case 0: "left";
			case 1: "down";
			case 2: "up";
			case 3: "right";
			default: "unknown";
		}
	}
}