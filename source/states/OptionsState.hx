package states;

class OptionsState extends ExtendableState {
	final options:Array<String> = [
		"FPS Counter",
		#if desktop "Fullscreen", #end
		"Antialiasing",
		"Downscroll",
		"Flashing Lights",
		"Botplay",
		"Framerate",
		"Song Speed",
		"Hitsound Volume",
		"Language",
		"Controls"
	];
	var grpOptions:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var daText:FlxText;

	var checkerArray:Array<Checker> = [];

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length) {
			var optionTxt:FlxText = new FlxText(20, 20 + (i * 50), 0, options[i], 32);
			optionTxt.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionTxt.ID = i;
			grpOptions.add(optionTxt);

			if (i < 6) {
				var checker:Checker = new Checker(0, 0, getOptionState(i));
				checker.sprTracker = optionTxt;
				checkerArray.push(checker);
				add(checker);
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

		if (options[curSelected] == "Framerate") {
			if (Input.is('right') || Input.is('left')) {
				FlxG.sound.play(Paths.sound('scroll'));
				if (!Input.is('left'))
					SaveData.settings.framerate += (SaveData.settings.framerate == 240) ? 0 : 10;
				else
					SaveData.settings.framerate -= (SaveData.settings.framerate == 60) ? 0 : 10;

				Main.updateFramerate(SaveData.settings.framerate);
			}
		} else if (options[curSelected] == "Song Speed") {
			if (Input.is('right') || Input.is('left')) {
				FlxG.sound.play(Paths.sound('scroll'));
				if (!Input.is('left'))
					SaveData.settings.songSpeed += (SaveData.settings.songSpeed == 10) ? 0 : 1;
				else
					SaveData.settings.songSpeed -= (SaveData.settings.songSpeed == 1) ? 0 : 1;
			}
		} else if (options[curSelected] == "Hitsound Volume") {
			if (Input.is('right') || Input.is('left')) {
				FlxG.sound.play(Paths.sound('scroll'));
				if (!Input.is('left'))
					SaveData.settings.hitSoundVolume = Math.min(1, SaveData.settings.hitSoundVolume + 0.1);
				else
					SaveData.settings.hitSoundVolume = Math.max(0, SaveData.settings.hitSoundVolume - 0.1);
			}
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
				case "Downscroll":
					SaveData.settings.downScroll = !SaveData.settings.downScroll;
				case "Flashing Lights":
					SaveData.settings.flashing = !SaveData.settings.flashing;
				case "Botplay":
					SaveData.settings.botPlay = !SaveData.settings.botPlay;
				case "Controls":
					ExtendableState.switchState(new ControlsState());
				case "Language":
					openSubState(new LanguageSubState());
			}

			for (i in 0...checkerArray.length) {
				checkerArray[i].checked = getOptionState(i);
				checkerArray[i].animation.play((checkerArray[i].checked) ? "check" : "uncheck");
			}

			updateText();
		}

		if (Input.is('exit')) {
			ExtendableState.switchState(new MenuState());
			FlxG.sound.play(Paths.sound('cancel'));
			SaveData.saveSettings();
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
				daText.text = "Toggles downscroll. Set to: " + SaveData.settings.downScroll;
			case 4:
				daText.text = "Toggles flashing lights. Turn this off if you're photosensitive. Set to: " + SaveData.settings.flashing;
			case 5:
				daText.text = "Toggles botplay. Set to: " + SaveData.settings.botPlay;
			case 6:
				daText.text = "Use LEFT/RIGHT to change the framerate (Max 240). Set to: " + SaveData.settings.framerate;
			case 7:
				daText.text = "Use LEFT/RIGHT to change the default song speed (Max 10). Set to: " + SaveData.settings.songSpeed;
			case 8:
				daText.text = "Use LEFT/RIGHT to change the hitsound volume (Max 1). Set to: " + SaveData.settings.hitSoundVolume;
			case 9:
				daText.text = "Changes the language. Set to: " + SaveData.settings.lang;
			case 10:
				daText.text = "Edit your controls.";
		}
	}

	function getOptionState(index:Int):Bool {
		switch (index) {
			case 0:
				return SaveData.settings.fpsCounter;
			case 1:
				return SaveData.settings.fullscreen;
			case 2:
				return SaveData.settings.antialiasing;
			case 3:
				return SaveData.settings.downScroll;
			case 4:
				return SaveData.settings.flashing;
			case 5:
				return SaveData.settings.botPlay;
			default:
				return false;
		}
	}
}