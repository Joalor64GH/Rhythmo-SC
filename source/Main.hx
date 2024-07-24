package;

class Main extends openfl.display.Sprite {
	public final config:Dynamic = {
		gameDimensions: [720, 720],
		initialState: MenuState,
		defaultFPS: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public function new() {
		super();

		SaveData.init();
		Localization.init({
			languages: ['en', 'es'],
			directory: "languages",
			default_language: "en"
		});

		trace('current platform: ${PlatformUtil.getPlatform()}');

		addChild(new FlxGame(config.gameDimensions[0], config.gameDimensions[1], config.initialState, 
			config.defaultFPS, config.defaultFPS, config.skipSplash, config.startFullscreen));
		addChild(new FPS(10, 10, 0xFFFFFF));
	}
}