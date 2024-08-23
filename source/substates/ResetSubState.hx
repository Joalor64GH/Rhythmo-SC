package substates;

class ResetSubState extends ExtendableSubState {
	var song:String;

	public function new(song:String) {
		this.song = song;

		super();

		var name:String = song;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		bg.screenCenter();
		bg.alpha = 0.6;
		add(bg);

		var text:FlxText = new FlxText(0, 0, FlxG.width, 'Reset the score of\n$name?', 12);
		text.setFormat(Paths.font('vcr.ttf'), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter();
		add(text);

		var text2:FlxText = new FlxText(0, text.y + 100, 0, "Y - Yes // N - No", 12);
		text2.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text2.screenCenter(X);
		add(text2);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var yes = Input.is('y') || (gamepad != null ? Input.gamepadIs('start') : false);
		var no = Input.is('n') || (gamepad != null ? Input.gamepadIs('back') : false);
		var exit = Input.is('exit') || (gamepad != null ? Input.gamepadIs('gamepad_exit') : false);

		if (yes) {
			FlxG.sound.play(Paths.sound('select'));
			HighScore.resetSong(song);
			close();
		} else if (no || exit) {
			FlxG.sound.play(Paths.sound('cancel'));
			close();
		}
	}
}