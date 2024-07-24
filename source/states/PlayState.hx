package states;

class PlayState extends FlxState {
	override function create() {
		super.create();

		SaveData.init();
		Localization.init({
			languages: ['en', 'es'],
			directory: "languages",
			default_language: "en"
		});

		trace('${PlatformUtil.getPlatform()}');

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}