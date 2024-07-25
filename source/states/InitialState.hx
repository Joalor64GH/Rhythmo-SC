package states;

class InitialState extends FlxState {
    var intro:FlxSprite;
    var logo:FlxSprite;
    var bg:FlxSprite;

    override function create() {
        super.create();

        SaveData.init();
		Localization.init({
			languages: ['en', 'es'],
			directory: "languages",
			default_language: "en"
		});

		trace('current platform: ${PlatformUtil.getPlatform()}');

        intro = new FlxSprite().loadGraphic(Paths.image('title/credist'));
        intro.alpha = 0;
        add(intro);

        bg = new FlxSprite().loadGraphic(Paths.image('title/title_bg'));
        bg.alpha = 0;
        add(bg);

        logo = new FlxSprite(0, 0).loadGraphic(Paths.image('title/logo'));
        logo.scale.set(0.4, 0.4);
        logo.alpha = 0;
        add(logo);

        FlxTween.tween(intro, {alpha: 1}, 1, {ease: FlxEase.quadOut});
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

        // i know this code looks bad, but it works
        new FlxTimer().start(3, (tmr:FlxTimer) -> {
            FlxTween.tween(intro, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
            FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
            FlxTween.tween(logo, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
            new FlxTimer().start(4.5, (tmr:FlxTimer) -> {
                FlxTween.tween(logo, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
                new FlxTimer().start(0.5, (tmr:FlxTimer) -> {
                    FlxG.switchState(MenuState.new);
                });
            });
        });
	}
}