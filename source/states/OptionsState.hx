package states;

class OptionsState extends ExtendableState {
	final options:Array<String> = [
		Localization.get("opFPS", SaveData.settings.lang),
		#if desktop
		Localization.get("opFlScrn", SaveData.settings.lang),
		#end
		Localization.get("opAnti", SaveData.settings.lang),
		Localization.get("opDwnScrl", SaveData.settings.lang),
		Localization.get("opFlash", SaveData.settings.lang),
		Localization.get("opBot", SaveData.settings.lang),
		Localization.get("opFrm", SaveData.settings.lang),
		Localization.get("opSpeed", SaveData.settings.lang),
		Localization.get("opHitSnd", SaveData.settings.lang),
		Localization.get("opLang", SaveData.settings.lang),
		Localization.get("opCtrls", SaveData.settings.lang),
		Localization.get("opReset", SaveData.settings.lang)
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

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var up = Input.is('up') || (gamepad != null ? Input.gamepadIs('gamepad_up') : false);
		var down = Input.is('down') || (gamepad != null ? Input.gamepadIs('gamepad_down') : false);
		var left = Input.is('left') || (gamepad != null ? Input.gamepadIs('gamepad_left') : false);
		var right = Input.is('right') || (gamepad != null ? Input.gamepadIs('gamepad_right') : false);
		var accept = Input.is('accept') || (gamepad != null ? Input.gamepadIs('gamepad_accept') : false);
		var exit = Input.is('exit') || (gamepad != null ? Input.gamepadIs('gamepad_exit') : false);

		if (up || down)
			changeSelection(up ? -1 : 1);

		if (curSelected == 6) {
			if (right || left) {
				FlxG.sound.play(Paths.sound('scroll'));
				if (!left)
					SaveData.settings.framerate += (SaveData.settings.framerate == 240) ? 0 : 10;
				else
					SaveData.settings.framerate -= (SaveData.settings.framerate == 60) ? 0 : 10;

				Main.updateFramerate(SaveData.settings.framerate);
			}
		} else if (curSelected == 7) {
			if (right || left) {
				FlxG.sound.play(Paths.sound('scroll'));
				if (!left)
					SaveData.settings.songSpeed += (SaveData.settings.songSpeed == 10) ? 0 : 1;
				else
					SaveData.settings.songSpeed -= (SaveData.settings.songSpeed == 1) ? 0 : 1;
			}
		} else if (curSelected == 8) {
			if (right || left) {
				FlxG.sound.play(Paths.sound('scroll'));
				if (!left)
					SaveData.settings.hitSoundVolume = Math.min(1, SaveData.settings.hitSoundVolume + 0.1);
				else
					SaveData.settings.hitSoundVolume = Math.max(0, SaveData.settings.hitSoundVolume - 0.1);
			}
		}

		if (accept) {
			if (curSelected == 0) {
				SaveData.settings.fullscreen = !SaveData.settings.fullscreen;
				FlxG.fullscreen = SaveData.settings.fullscreen;
			} else if (curSelected == 1) {
				SaveData.settings.fpsCounter = !SaveData.settings.fpsCounter;
				if (Main.fpsDisplay != null)
					Main.fpsDisplay.visible = SaveData.settings.fpsCounter;
			} else if (curSelected == 2)
				SaveData.settings.antialiasing = !SaveData.settings.antialiasing;
			else if (curSelected == 3)
				SaveData.settings.downScroll = !SaveData.settings.downScroll;
			else if (curSelected == 4)
				SaveData.settings.flashing = !SaveData.settings.flashing;
			else if (curSelected == 5)
				SaveData.settings.botPlay = !SaveData.settings.botPlay;
			else if (curSelected == 9)
				openSubState(new LanguageSubState());
			else if (curSelected == 10)
				ExtendableState.switchState(new ControlsState());
			else if (curSelected == 11) {
				openSubState(new PromptSubState("Are you sure?", () -> {
					SaveData.eraseData();
					ExtendableState.resetState();
				}, () -> {
					closeSubState();
				}));
			}

			for (i in 0...checkerArray.length) {
				checkerArray[i].checked = getOptionState(i);
				checkerArray[i].animation.play((checkerArray[i].checked) ? "check" : "uncheck");
			}

			updateText();
		}

		if (exit) {
			ExtendableState.switchState(new MenuState());
			FlxG.sound.play(Paths.sound('cancel'));
			SaveData.saveSettings();
		}
	}

	override function closeSubState() {
		super.closeSubState();
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
				daText.text = Localization.get("descFPS", SaveData.settings.lang) + SaveData.settings.fpsCounter;
			case 1:
				daText.text = Localization.get("descFlScrn", SaveData.settings.lang) + SaveData.settings.fullscreen;
			case 2:
				daText.text = Localization.get("descAnti", SaveData.settings.lang) + SaveData.settings.antialiasing;
			case 3:
				daText.text = Localization.get("descDwnScrl", SaveData.settings.lang) + SaveData.settings.downScroll;
			case 4:
				daText.text = Localization.get("descFlash", SaveData.settings.lang) + SaveData.settings.flashing;
			case 5:
				daText.text = Localization.get("descBot", SaveData.settings.lang) + SaveData.settings.botPlay;
			case 6:
				daText.text = Localization.get("descFrm", SaveData.settings.lang) + SaveData.settings.framerate;
			case 7:
				daText.text = Localization.get("descSpeed", SaveData.settings.lang) + SaveData.settings.songSpeed;
			case 8:
				daText.text = Localization.get("descHitSnd", SaveData.settings.lang) + SaveData.settings.hitSoundVolume;
			case 9:
				daText.text = Localization.get("descLang", SaveData.settings.lang) + SaveData.settings.lang;
			case 10:
				daText.text = Localization.get("descCtrls", SaveData.settings.lang);
			case 11:
				daText.text = Localization.get("descReset", SaveData.settings.lang);
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

class Checker extends GameSprite {
	public var checked:Bool = true;
	public var sprTracker:FlxSprite;

	public function new(x:Float = 0, y:Float = 0, checked:Bool = true) {
		super(x, y);

		this.checked = checked;

		loadGraphic(Paths.image('menu/checker'), true, 400, 400);
		setGraphicSize(65, 65);
		scrollFactor.set();
		updateHitbox();

		animation.add("check", [0], 1);
		animation.add("uncheck", [1], 1);
		animation.play((checked) ? "check" : "uncheck");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y);
	}
}