package states;

class InitialState extends ExtendableState {
	var intro:FlxSprite;

	override function create() {
		super.create();

		Localization.loadLanguages();
		SaveData.init();
		HighScore.load();

		trace('current platform: ${PlatformUtil.getPlatform()}');

		#if desktop
		UpdateState.updateCheck();
		#else
		trace('Sorry! No update support on: ${PlatformUtil.getPlatform()}!');
		#end

		intro = new FlxSprite().loadGraphic(Paths.image('menu/title/intro'));
		intro.screenCenter();
		intro.alpha = 0;
		add(intro);

		FlxTween.tween(intro, {alpha: 1}, 1, {ease: FlxEase.quadOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.is("accept"))
			ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
		else {
			new FlxTimer().start(3, (tmr:FlxTimer) -> {
				ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
			});
		}
	}
}