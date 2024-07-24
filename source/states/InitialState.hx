package states;

class InitialState extends FlxState {
    var intro:FlxSprite;

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

        FlxTween.tween(intro, {alpha: 1}, 1, {ease: FlxEase.quadOut});
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

        new FlxTimer().start(4, (tmr:FlxTimer) -> {
            FlxTween.tween(logo, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
            new FlxTimer().start(0.5, (tmr:FlxTimer) -> {
                FlxG.switchState(MenuState.new);
            })
        });
	}
}