package states;

class InitialState extends ExtendableState {
	var intro:FlxSprite;

	override function create() {
		super.create();

		SaveData.init();
		Localization.loadLanguages();
		Main.updateFramerate(SaveData.settings.framerate);
		HighScore.load();

		trace('current platform: ${PlatformUtil.getPlatform()}');

		intro = new FlxSprite().loadGraphic(Paths.image('title/credist'));
		intro.screenCenter();
		intro.alpha = 0;
		add(intro);

		FlxTween.tween(intro, {alpha: 1}, 1, {ease: FlxEase.quadOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.is("accept"))
			ExtendableState.switchState(new TitleState());
		else {
			new FlxTimer().start(3, (tmr:FlxTimer) -> {
				ExtendableState.switchState(new TitleState());
			});
		}
	}
}