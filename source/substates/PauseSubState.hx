package substates;

class PauseSubState extends ExtendableSubState { // to-do: add funny tip text
	public function new() {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.alpha = 0.55;
		add(bg);

		var text:FlxText = new FlxText(0, 0, 0, "PAUSED?", 12);
		text.setFormat(Paths.font('vcr.ttf'), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter();
		add(text);

		var text2:FlxText = new FlxText(0, text.y + 100, 0, "ENTER - Resume / R - Restart / BACKSPACE - Song Menu / ESCAPE - Main Menu", 12);
		text2.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text2.screenCenter(X);
		add(text2);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.is("exit") || Input.is("backspace")) {
			ExtendableState.switchState((Input.is("backspace")) ? new SongSelectState() : new MenuState());
			FlxG.sound.playMusic(Paths.sound('Basically_Professionally_Musically', true), 0.75);
			PlayState.chartingMode = false;
		} else if (Input.is("r"))
			ExtendableState.resetState();
		else if (Input.is("accept"))
			close();
	}
}