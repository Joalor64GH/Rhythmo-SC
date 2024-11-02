package options;

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

		FlxG.mouse.visible = true;

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);
		add(camFollow);

		bg = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		bg.color = 0xFFac21ff;
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

		switchSpr = new FlxSprite(5, FlxG.height - 44).makeGraphic(50, 50, FlxColor.BLACK); // placeholder for now
		switchSpr.scrollFactor.set();
		add(switchSpr);

		changeSelection(0, false);

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (gamepadMode) {
			switch (curSelected) {
				case 0:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('left').gamepad[0]);
				case 1:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('left').gamepad[1]);
				case 2:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('down').gamepad[0]);
				case 3:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('down').gamepad[1]);
				case 4:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('up').gamepad[0]);
				case 5:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('up').gamepad[1]);
				case 6:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('right').gamepad[0]);
				case 7:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('right').gamepad[1]);
				case 8:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('accept').gamepad[0]);
				case 9:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('exit').gamepad[0]);
				case 10:
					curControl.text = FlxGamepadInputID.toStringMap.get(Input.binds.get('reset').gamepad[0]);
			}
		} else {
			switch (curSelected) {
				case 0:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('left').key[0]);
				case 1:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('left').key[1]);
				case 2:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('down').key[0]);
				case 3:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('down').key[1]);
				case 4:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('up').key[0]);
				case 5:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('up').key[1]);
				case 6:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('right').key[0]);
				case 7:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('right').key[1]);
				case 8:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('accept').key[0]);
				case 9:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('exit').key[0]);
				case 10:
					curControl.text = FlxKey.toStringMap.get(Input.binds.get('reset').key[0]);
			}
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!isChangingBind) {
			if (Input.justPressed('up') || Input.justPressed('down'))
				changeSelection(Input.justPressed('up') ? -1 : 1);

			if (Input.justPressed('accept')) {
				isChangingBind = true;
				anyKeyTxt.text = "PRESS ANY KEY TO CONTINUE";
			}

			if (Input.justPressed('exit')) {
				persistentDraw = persistentUpdate = true;
				FlxG.mouse.visible = false;
				close();
			}

			if (FlxG.mouse.overlaps(switchSpr) && FlxG.mouse.justPressed) {
				gamepadMode = !gamepadMode;
				FlxTween.cancelTweensOf(bg);
				FlxTween.color(bg, 0.5, bg.color, gamepadMode ? 0xFF22ebf2 : 0xFFac21ff, {ease: FlxEase.linear});
				if (gamepad != null)
					FlxG.sound.play(Paths.sound('select'));
				else {
					gamepadMode = false;
					FlxG.sound.play(Paths.sound('cancel'));
					Main.toast.create("Can't do that.", 0xFFFFFF00, "Connect a controller to edit your gamepad controls.");
				}
			}
		} else {
			if (Input.justPressed('any')) {
				if (gamepadMode) {
					var keyPressed:FlxGamepadInputID = gamepad.firstJustPressedID();
					if (gamepad != null && gamepad.anyJustPressed([ANY]) && keyPressed.toString() != FlxGamepadInputID.NONE) {
						switch (curSelected) {
							case 0:
								SaveData.settings.gamepadBinds[0][0] = keyPressed;
							case 1:
								SaveData.settings.gamepadBinds[0][1] = keyPressed;
							case 2:
								SaveData.settings.gamepadBinds[1][0] = keyPressed;
							case 3:
								SaveData.settings.gamepadBinds[1][1] = keyPressed;
							case 4:
								SaveData.settings.gamepadBinds[2][0] = keyPressed;
							case 5:
								SaveData.settings.gamepadBinds[2][1] = keyPressed;
							case 6:
								SaveData.settings.gamepadBinds[3][0] = keyPressed;
							case 7:
								SaveData.settings.gamepadBinds[3][1] = keyPressed;
							case 8:
								SaveData.settings.gamepadBinds[4][0] = keyPressed;
							case 9:
								SaveData.settings.gamepadBinds[5][0] = keyPressed;
							case 10:
								SaveData.settings.gamepadBinds[6][0] = keyPressed;
						}
					}
				} else {
					var pressedKey = FlxG.keys.getIsDown();
					if (pressedKey.length > 0) {
						var keyDown = pressedKey[0].ID;
						switch (curSelected) {
							case 0:
								SaveData.settings.keyboardBinds[0][0] = keyDown;
							case 1:
								SaveData.settings.keyboardBinds[0][1] = keyDown;
							case 2:
								SaveData.settings.keyboardBinds[1][0] = keyDown;
							case 3:
								SaveData.settings.keyboardBinds[1][1] = keyDown;
							case 4:
								SaveData.settings.keyboardBinds[2][0] = keyDown;
							case 5:
								SaveData.settings.keyboardBinds[2][1] = keyDown;
							case 6:
								SaveData.settings.keyboardBinds[3][0] = keyDown;
							case 7:
								SaveData.settings.keyboardBinds[3][1] = keyDown;
							case 8:
								SaveData.settings.keyboardBinds[4][0] = keyDown;
							case 9:
								SaveData.settings.keyboardBinds[5][0] = keyDown;
							case 10:
								SaveData.settings.keyboardBinds[6][0] = keyDown;
						}
					}
				}
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