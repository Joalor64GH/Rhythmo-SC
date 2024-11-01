package options;

// not much functionality yet until i actually do some stuff idk
class ControlsSubState extends ExtendableSubState {
	var coolControls:Array<String> = [
		"Left", "Left (Alt)", "Down", "Down (Alt)", "Up", "Up (Alt)", "Right", "Right (Alt)", "Accept", "Exit", "Restart"
	];

	var ctrlGroup:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var camFollow:FlxObject;
	var isChangingBind:Bool = false;
	var gamepadMode:Bool = false;

	var anyKeyTxt:FlxText;
	var curControl:FlxText;

	var switchSpr:FlxSprite;

	var bg:FlxSprite;

	public function new() {
		super();

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);
		add(camFollow);

		bg = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		ctrlGroup = new FlxTypedGroup<FlxText>();
		add(ctrlGroup);

		for (i in 0...coolControls.length) {
			var bindTxt:FlxText = new FlxText(20, 20 + (i * 80), 0, coolControls[i], 32);
			bindTxt.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			bindTxt.ID = i;
			ctrlGroup.add(bindTxt);
		}

		anyKeyTxt = new FlxText(0, 0, 0, "", 12);
		anyKeyTxt.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		anyKeyTxt.scrollFactor.set();
		anyKeyTxt.screenCenter();
		add(anyKeyTxt);

		curControl = new FlxText(700, 0, 0, "", 12);
		curControl.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curControl.scrollFactor.set();
		curControl.screenCenter(Y);
		add(curControl);

		switchSpr = new FlxSprite(5, FlxG.height - 24).makeGraphic(50, 50, FlxColor.BLACK); // placeholder for now
		switchSpr.scrollFactor.set();
		add(switchSpr);

		changeSelection(0, false);

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!isChangingBind) {
			if (Input.justPressed('up') || Input.justPressed('down'))
				changeSelection(Input.justPressed('up') ? -1 : 1);

			if (Input.justPressed('accept')) {
				isChangingBind = true;
				anyKeyTxt.text = "PRESS ANY KEY TO CONTINUE";
			}

			if (Input.justPressed('exit')) {
				persistentDraw = persistentUpdate = true;
				close();
			}
		}

		switch (curSelected) {
			if (gamepadMode) {
				case 0:
					curControl.text = SaveData.settings.gamepadBinds[0][0].toString();
				case 1:
					curControl.text = SaveData.settings.gamepadBinds[0][1].toString();
				case 2:
					curControl.text = SaveData.settings.gamepadBinds[1][0].toString();
				case 3:
					curControl.text = SaveData.settings.gamepadBinds[1][1].toString();
				case 4:
					curControl.text = SaveData.settings.gamepadBinds[2][0].toString();
				case 5:
					curControl.text = SaveData.settings.gamepadBinds[2][1].toString();
				case 6:
					curControl.text = SaveData.settings.gamepadBinds[3][0].toString();
				case 7:
					curControl.text = SaveData.settings.gamepadBinds[3][1].toString();
				case 8:
					curControl.text = SaveData.settings.gamepadBinds[4][0].toString();
				case 9:
					curControl.text = SaveData.settings.gamepadBinds[5][0].toString();
				case 10:
					curControl.text = SaveData.settings.gamepadBinds[6][0].toString();
			} else {
				case 0:
					curControl.text = SaveData.settings.keyboardBinds[0][0].toString();
				case 1:
					curControl.text = SaveData.settings.keyboardBinds[0][1].toString();
				case 2:
					curControl.text = SaveData.settings.keyboardBinds[1][0].toString();
				case 3:
					curControl.text = SaveData.settings.keyboardBinds[1][1].toString();
				case 4:
					curControl.text = SaveData.settings.keyboardBinds[2][0].toString();
				case 5:
					curControl.text = SaveData.settings.keyboardBinds[2][1].toString();
				case 6:
					curControl.text = SaveData.settings.keyboardBinds[3][0].toString();
				case 7:
					curControl.text = SaveData.settings.keyboardBinds[3][1].toString();
				case 8:
					curControl.text = SaveData.settings.keyboardBinds[4][0].toString();
				case 9:
					curControl.text = SaveData.settings.keyboardBinds[5][0].toString();
				case 10:
					curControl.text = SaveData.settings.keyboardBinds[6][0].toString();
			}
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (isChangingBind) {
			if (Input.justPressed('any')) {
				/*if (gamepadMode) {
					var keyPressed:FlxGamepadInputID = gamepad.firstJustPressedID();
					if (gamepad != null && gamepad.anyJustPressed([ANY]) && keyPressed.toString() != NONE) {
						// nothing yet
					}
				} else {*/
					switch (curSelected) {
						case 0:
							SaveData.settings.keyboardBinds[0][0] = FlxG.keys.getIsDown()[0].ID.toString();
						case 1:
							SaveData.settings.keyboardBinds[0][1] = FlxG.keys.getIsDown()[0].ID.toString();
						case 2:
							SaveData.settings.keyboardBinds[1][0] = FlxG.keys.getIsDown()[0].ID.toString();
						case 3:
							SaveData.settings.keyboardBinds[1][1] = FlxG.keys.getIsDown()[0].ID.toString();
						case 4:
							SaveData.settings.keyboardBinds[2][0] = FlxG.keys.getIsDown()[0].ID.toString();
						case 5:
							SaveData.settings.keyboardBinds[2][1] = FlxG.keys.getIsDown()[0].ID.toString();
						case 6:
							SaveData.settings.keyboardBinds[3][0] = FlxG.keys.getIsDown()[0].ID.toString();
						case 7:
							SaveData.settings.keyboardBinds[3][1] = FlxG.keys.getIsDown()[0].ID.toString();
						case 8:
							SaveData.settings.keyboardBinds[4][0] = FlxG.keys.getIsDown()[0].ID.toString();
						case 9:
							SaveData.settings.keyboardBinds[5][0] = FlxG.keys.getIsDown()[0].ID.toString();
						case 10:
							SaveData.settings.keyboardBinds[6][0] = FlxG.keys.getIsDown()[0].ID.toString();
					}
				// }
				SaveData.saveSettings();
				Input.refreshControls();
				FlxG.sound.play(Paths.sound('select'));
				isChangingBind = false;
				anyKeyTxt.text = "";
			}
		}
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, coolControls.length - 1);
		ctrlGroup.forEach(function(txt:FlxText) {
			txt.alpha = (txt.ID == curSelected) ? 1 : 0.6;
			if (txt.ID == curSelected)
				camFollow.y = txt.y;
		});
	}
}