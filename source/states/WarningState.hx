package states;

class WarningState extends ExtendableState {
	public static var leftState:Bool = false;
	var bg:FlxSprite;

	override function create() {
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('title/warning'));
		add(bg);
	}

	override function update(elapsed:Float) {
		if (!leftState) {
			var accept:Bool = Input.is("accept");
			if (Input.is("exit") || accept) {
				leftState = true;
				FlxG.sound.play(Paths.sound('cancel'));
				FlxTween.tween(bg, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween) {
						ExtendableState.switchState(new InitialState());
					}
				});

				if (!accept) {
					SaveData.settings.flashing = false;
					SaveData.saveSettings();
				}
			}
		}
		super.update(elapsed);
	}
}