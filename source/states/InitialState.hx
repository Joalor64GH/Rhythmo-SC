package states;

class InitialState extends ExtendableState {
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);
	var intro:FlxSprite;

	var timer:Float = 0;

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

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x003500ff, 0x55a800ff, 0xAAe200ff], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		gradientBar.scale.y = 0;
		add(gradientBar);
		FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});

		intro = new FlxSprite().loadGraphic(Paths.image('menu/title/intro'));
		intro.screenCenter();
		intro.alpha = 0;
		add(intro);
		FlxTween.tween(intro, {alpha: 1}, 1, {ease: FlxEase.quadOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		timer++;

		gradientBar.scale.y += Math.sin(timer / 10) * 0.001;
		gradientBar.updateHitbox();
		gradientBar.y = FlxG.height - gradientBar.height;

		if (Input.justPressed('accept'))
			ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
		else {
			new FlxTimer().start(3, (tmr:FlxTimer) -> {
				ExtendableState.switchState((UpdateState.mustUpdate) ? new UpdateState() : new TitleState());
			});
		}
	}
}