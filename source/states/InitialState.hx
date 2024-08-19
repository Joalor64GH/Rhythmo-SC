package states;

class InitialState extends ExtendableState {
	var intro:FlxSprite;

	override function create() {
		super.create();

		Localization.loadLanguages();
		SaveData.init();
		HighScore.load();

		if (SaveData.settings.lang == null)
			SaveData.settings.lang = en;

		trace('current platform: ${PlatformUtil.getPlatform()}');

		#if desktop
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

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		var accept = Input.is('accept') || (gamepad != null ? Input.gamepadIs('gamepad_accept') : false);

		if (accept)
			ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
		else {
			new FlxTimer().start(3, (tmr:FlxTimer) -> {
				ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
			});
		}
	}
}