package states;

class InitialState extends ExtendableState {
	var intro:FlxSprite;

	override function create() {
		super.create();

		FlxG.mouse.visible = false;

		Localization.loadLanguages();
		Localization.switchLanguage(SaveData.settings.lang);
		
		ModHandler.reload();
		SaveData.init();
		Achievements.load();
		HighScore.load();

		trace('current platform: ${PlatformUtil.getPlatform()}');

		#if (desktop || UPDATE_CHECK)
		UpdateState.updateCheck();
		#else
		trace('Sorry! No update support on: ${PlatformUtil.getPlatform()}!');
		#end

		intro = new FlxSprite().loadGraphic(Paths.image('menu/title/intro'));
		intro.screenCenter();
		intro.alpha = 0;
		FlxTween.tween(intro, {alpha: 1}, 1, {ease: FlxEase.quadOut});
		add(intro);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('accept'))
			ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
		else {
			new FlxTimer().start(3, (tmr:FlxTimer) -> {
				ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
			});
		}
	}
}