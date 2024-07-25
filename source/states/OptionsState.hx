package states;

class OptionsState extends ExtendableState {
	final options:Array<String> = ["FPS Counter", #if desktop "Fullscreen", #end "Antialiasing", "Framerate", "Language", "Controls"];
	var grpOptions:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var daText:FlxText;

	var checkers:FlxTypedGroup<Checker>;

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('options/options_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		checkers = new FlxTypedGroup<Checker>();
		add(checkers);

		for (i in 0...options.length) {
			var optionTxt:FlxText = new FlxText(20, 20 + (i * 50), 0, options[i], 32);
			optionTxt.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionTxt.ID = i;
			grpOptions.add(optionTxt);

			if (i < 3) {
				var checked:Bool = getOptionState(i);
				var checker:Checker = new Checker(optionTxt.x + optionTxt.width + 20, optionTxt.y, checked);
				checkers.add(checker);
			}
		}

		daText = new FlxText(5, FlxG.height - 24, 0, "", 12);
		daText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(daText);

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		updateText();

		if (Input.is('up') || Input.is('down'))
			changeSelection(Input.is('up') ? -1 : 1);

		if (Input.is('exit')) {
			ExtendableState.switchState(new MenuState());
			FlxG.sound.play(Paths.sound('cancel'));
			SaveData.saveSettings();
		}

		if (Input.is("accept")) {
            switch (options[curSelected]) {
                #if desktop
                case "Fullscreen":
                    SaveData.settings.fullscreen = !SaveData.settings.fullscreen;
                    FlxG.fullscreen = SaveData.settings.fullscreen;
                #end
                case "FPS Counter":
                    SaveData.settings.fpsCounter = !SaveData.settings.fpsCounter;
                    if (Main.fpsDisplay != null)
                        Main.fpsDisplay.visible = SaveData.settings.fpsCounter;
                case "Antialiasing":
                    SaveData.settings.antialiasing = !SaveData.settings.antialiasing;
            }

			updateCheckers();
			updateText();
        }
	}

	private function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scroll'));

		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		grpOptions.forEach(function(txt:FlxText) {
			txt.alpha = (txt.ID == curSelected) ? 1 : 0.6;
		});
	}

	function updateText() {
		switch (curSelected) {
			case 0:
				daText.text = "Toggles the FPS Display. Set to: " + SaveData.settings.fpsCounter;
			case 1:
				daText.text = "Toggles fullscreen. Set to: " + SaveData.settings.fullscreen;
			case 2:
				daText.text = "Toggles global antialiasing. Set to: " + SaveData.settings.antialiasing;
			case 3:
				daText.text = "Use LEFT/RIGHT to change the framerate (Max 240). Set to: " + SaveData.settings.framerate;
			case 4:
				daText.text = "Changes the language. Set to: " + SaveData.settings.lang;
			case 5:
				daText.text = "Edit your controls.";
		}
	}

	function updateCheckers() {
		for (i in 0...checkers.length) {
			var checker:Checker = checkers.members[i];
			checker.checked = getOptionState(i);
			checker.animation.play((checker.checked) ? "check" : "uncheck");
		}
	}

	function getOptionState(index:Int):Bool {
		switch (index) {
			case 0: return SaveData.settings.fpsCounter;
			case 1: return SaveData.settings.fullscreen;
			case 2: return SaveData.settings.antialiasing;
			default: return false;
		}
	}
}