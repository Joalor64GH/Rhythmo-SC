package states;

class InitialState extends ExtendableState {
	var intro:FlxSprite;

	override function create() {
		super.create();

		SaveData.init();
		Localization.init({
			languages: ['en', 'es'],
			directory: "languages",
			default_language: "en"
		});
		Main.updateFramerate(SaveData.settings.framerate);

		trace('current platform: ${PlatformUtil.getPlatform()}');

		intro = new FlxSprite().loadGraphic(Paths.image('title/credist'));
		intro.alpha = 0;
		add(intro);

		FlxTween.tween(intro, {alpha: 1}, 1, {ease: FlxEase.quadOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		new FlxTimer().start(3, (tmr:FlxTimer) -> {
			ExtendableState.switchState(new TitleState());
		});
	}
}