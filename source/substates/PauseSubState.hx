package substates;

class PauseSubState extends ExtendableSubState {
	public static var fromPlayState:Bool = false;

	var tipTxt:FlxText;
	var isTweening:Bool = false;
	var lastString:String = '';

	public function new() {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.alpha = 0.55;
		add(bg);

		var text:FlxText = new FlxText(0, 0, 0, Localization.get("pauseTxt", SaveData.settings.lang), 12);
		text.setFormat(Paths.font('vcr.ttf'), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter();
		add(text);

		var text2:FlxText = new FlxText(0, text.y + 100, 0, Localization.get("pauseCtrls", SaveData.settings.lang), 12);
		text2.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text2.screenCenter(X);
		add(text2);

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.65;
		add(bottomPanel);

		tipTxt = new FlxText(20, FlxG.height - 80, 1000, "", 22);
		tipTxt.setFormat(Paths.font('vcr.ttf'), 26, 0xFFffffff, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(tipTxt);
	}

	var timer:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (isTweening) {
			tipTxt.screenCenter(X);
			timer = 0;
		} else {
			tipTxt.screenCenter(X);
			timer += elapsed;
			if (timer >= 3)
				changeText();
		}

		if (Input.justPressed('exit') || Input.justPressed('shift')) {
			ExtendableState.switchState((Input.justPressed('shift')) ? new SongSelectState() : new MenuState());
			FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
			PlayState.chartingMode = false;
			FlxG.mouse.visible = true;
		} else if (Input.justPressed('o')) {
			ExtendableState.switchState(new OptionsState());
			FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
			fromPlayState = true;
			FlxG.mouse.visible = true;
		} else if (Input.justPressed('reset'))
			ExtendableState.resetState();
		else if (Input.justPressed('accept'))
			close();
	}

	function changeText() {
		var selectedText:String = '';
		var textArray:Array<String> = Paths.getText(Paths.txt('tipText'));

		tipTxt.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(tipTxt, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: (twn:FlxTween) -> {
				if (selectedText != lastString) {
					tipTxt.text = selectedText;
					lastString = selectedText;
				} else {
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					tipTxt.text = selectedText;
				}

				tipTxt.alpha = 0;

				FlxTween.tween(tipTxt, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: (twn:FlxTween) -> {
						isTweening = false;
					}
				});
			}
		});
	}
}