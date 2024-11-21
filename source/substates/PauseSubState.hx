package substates;

class PauseSubState extends ExtendableSubState {
	var tipTxt:FlxText;
	var isTweening:Bool = false;
	var lastString:String = '';

	final pauseOptions:Array<String> = ['Resume', 'Restart', 'Options', 'Song Menu', 'Main Menu'];
	var pauseGrp:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;

	public function new() {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.alpha = 0.55;
		add(bg);

		var text:FlxText = new FlxText(0, 0, 0, Localization.get("pauseTxt", SaveData.settings.lang), 12);
		text.setFormat(Paths.font('vcr.ttf'), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);

		pauseGrp = new FlxTypedGroup<FlxText>();
		add(pauseGrp);

		for (i in 0...pauseOptions.length) {
			var text:FlxText = new FlxText(0, 250 + (i * 60), 0, pauseOptions[i], 32);
			text.setFormat(Paths.font('vcr.ttf'), 80, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.screenCenter(X);
			text.ID = i;
			pauseGrp.add(text);
		}

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.65;
		add(bottomPanel);

		tipTxt = new FlxText(20, FlxG.height - 80, 1000, "", 22);
		tipTxt.setFormat(Paths.font('vcr.ttf'), 26, 0xFFffffff, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(tipTxt);

		changeSelection(0, false);
	}

	var timer:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		tipTxt.screenCenter(X);

		if (isTweening)
			timer = 0;
		else {
			timer += elapsed;
			if (timer >= 3)
				changeText();
		}

		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		if (Input.justPressed('accept')) {
			switch (curSelected) {
				case 0:
					close();
				case 1:
					FlxG.resetState();
				case 2:
					ExtendableState.switchState(new options.OptionsState(true));
					FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
				case 3:
					ExtendableState.switchState(new SongSelectState());
					FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
					PlayState.chartingMode = false;
				case 4:
					ExtendableState.switchState(new MenuState());
					FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
					PlayState.chartingMode = false;
			}
		}
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, pauseOptions.length - 1);
		pauseGrp.forEach(function(txt:FlxText) {
			txt.color = (txt.ID == curSelected) ? FlxColor.LIME : FlxColor.WHITE;
		});
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