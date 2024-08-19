package states;

class UpdateState extends ExtendableState {
	public static var mustUpdate:Bool = false;
	public static var daJson:Dynamic;

	override function create() {
		super.create();

		var text:FlxText = new FlxText(0, 0, FlxG.width,
			"Hey! You're running an outdated version of Rhythmo!"
			+ '\nYour current version is v${Lib.application.meta.get('version')}, while the most recent version is v${daJson.version}!\n
			What\'s New:\n'
			+ daJson.description
			+ '\nPress ENTER to go to GitHub. Otherwise, press ESCAPE to proceed anyways.\n
			Thanks for playing!', 32);
		text.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(XY);
		add(text);
	}

	public static function updateCheck() {
		trace('checking for updates...');
		var http = new Http('https://raw.githubusercontent.com/Joalor64GH/Rhythmo-SC/main/gitVersion.json');
		http.onData = (data:String) -> {
			var daRawJson:Dynamic = Json.parse(data);
			if (daRawJson.version != Lib.application.meta.get('version')) {
				trace('oh noo outdated!!');
				daJson = daRawJson;
				mustUpdate = true;
			} else
				mustUpdate = false;
		}

		http.onError = (error) -> trace('error: $error');
		http.request();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var accept = Input.is('accept') || (gamepad != null ? Input.gamepadIs('gamepad_accept') : false);
		var exit = Input.is('exit') || (gamepad != null ? Input.gamepadIs('gamepad_exit') : false);

		if (accept) {
			FlxG.sound.play(Paths.sound('select'));
			#if linux
			Sys.command('/usr/bin/xdg-open', ["https://github.com/Joalor64GH/Rhythmo-SC/releases/latest"]);
			#else
			FlxG.openURL("https://github.com/Joalor64GH/Rhythmo-SC/releases/latest");
			#end
		} else if (exit) {
			ExtendableState.switchState(new TitleState());
			FlxG.sound.play(Paths.sound('cancel'));
		}
	}
}