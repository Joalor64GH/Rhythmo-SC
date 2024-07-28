package states;

class ControlsState extends ExtendableState {
	var init:Int = 0;
	var inChange:Bool = false;
	var keyboardMode:Bool = true;
	var controllerSpr:FlxSprite;
	
	var text1:FlxText;
	var text2:FlxText;

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('options/options_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		controllerSpr = new FlxSprite(50, 40).makeGraphic(82, 60, FlxColor.BLACK); // placeholder
		add(controllerSpr);

		var instructionsTxt:FlxText = new FlxText(5, FlxG.height - 24, 0, "Press LEFT/RIGHT to scroll through keys.", 12);
		instructionsTxt.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		instructionsTxt.screenCenter(X);
		add(instructionsTxt);

		text1 = new FlxText(0, 0, 0, "", 64);
		text1.setFormat(Paths.font('vcr.ttf'), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text1);

		text2 = new FlxText(5, FlxG.height - 54, 0, "", 32);
		text2.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text2);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		text1.screenCenter(XY);
		text2.screenCenter(X);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (FlxG.mouse.overlaps(controllerSpr)) {
			if (FlxG.mouse.justPressed) {
				keyboardMode = !keyboardMode;
				if (gamepad != null)
					FlxG.sound.play(Paths.sound('confirm'));
				else if (gamepad == null) {
					keyboardMode = true;
					FlxG.sound.play(Paths.sound('cancel'));
				}
			}
		}

		if (keyboardMode) {
			if ((Input.is('exit') || Input.is('backspace')) && !inChange)
				ExtendableState.switchState(new OptionsState());

			if (Input.is('accept')) {
				inChange = true;
				text2.text = "PRESS ANY KEY TO CONTINUE";
			}

			if (Input.is('left') && !inChange) {
				FlxG.sound.play(Paths.sound('scroll'));
				(init == 0) ? init = 5 : init--;
			}

			if (Input.is('right') && !inChange) {
				FlxG.sound.play(Paths.sound('scroll'));
				(init == 5) ? init = 0 : init++;
			}

			switch (init) {
				case 0:
					text1.text = "LEFT KEY: " + SaveData.settings.keyboardBinds[0].toString();
				case 1:
					text1.text = "DOWN KEY: " + SaveData.settings.keyboardBinds[1].toString();
				case 2:
					text1.text = "UP KEY: " + SaveData.settings.keyboardBinds[2].toString();
				case 3:
					text1.text = "RIGHT KEY: " + SaveData.settings.keyboardBinds[3].toString();
				case 4:
					text1.text = "ACCEPT KEY: " + SaveData.settings.keyboardBinds[4].toString();
				case 5:
					text1.text = "EXIT KEY: " + SaveData.settings.keyboardBinds[5].toString();
			}

			if (inChange) {
				if (!Input.is('accept') && !Input.is('exit') && Input.is('any')) {
					switch (init) {
						case 0:
							SaveData.settings.keyboardBinds[0] = FlxG.keys.getIsDown()[0].ID.toString();
							Input.actionMap.set("left", SaveData.settings.keyboardBinds[0]);
						case 1:
							SaveData.settings.keyboardBinds[1] = FlxG.keys.getIsDown()[0].ID.toString();
							Input.actionMap.set("down", SaveData.settings.keyboardBinds[1]);
						case 2:
							SaveData.settings.keyboardBinds[2] = FlxG.keys.getIsDown()[0].ID.toString();
							Input.actionMap.set("up", SaveData.settings.keyboardBinds[2]);
						case 3:
							SaveData.settings.keyboardBinds[3] = FlxG.keys.getIsDown()[0].ID.toString();
							Input.actionMap.set("right", SaveData.settings.keyboardBinds[3]);
						case 4:
							SaveData.settings.keyboardBinds[4] = FlxG.keys.getIsDown()[0].ID.toString();
							Input.actionMap.set("accept", SaveData.settings.keyboardBinds[4]);
						case 5:
							SaveData.settings.keyboardBinds[5] = FlxG.keys.getIsDown()[0].ID.toString();
							Input.actionMap.set("exit", SaveData.settings.keyboardBinds[5]);
					}
					FlxG.sound.play(Paths.sound('scroll'));
					text2.text = "";
					inChange = false;
				}
			}
		} else if (!keyboardMode) {
			if (gamepad != null) {
				if (Input.gamepadIs('gamepad_exit') || Input.gamepadIs('x') && !inChange)
					ExtendableState.switchState(new OptionsState());

				if (Input.gamepadIs('gamepad_accept')) {
					inChange = true;
					text2.text = "PRESS ANY KEY TO CONTINUE";
				}

				if (Input.gamepadIs('gamepad_left') && !inChange) {
					FlxG.sound.play(Paths.sound('scroll'));
					(init == 0) ? init = 5 : init--;
				}

				if (Input.gamepadIs('gamepad_right') && !inChange) {
					FlxG.sound.play(Paths.sound('scroll'));
					(init == 5) ? init = 0 : init++;
				}

				switch (init) {
					case 0:
						text1.text = "LEFT KEY: " + SaveData.settings.gamepadBinds[0].toString();
					case 1:
						text1.text = "DOWN KEY: " + SaveData.settings.gamepadBinds[1].toString();
					case 2:
						text1.text = "UP KEY: " + SaveData.settings.gamepadBinds[2].toString();
					case 3:
						text1.text = "RIGHT KEY: " + SaveData.settings.gamepadBinds[3].toString();
					case 4:
						text1.text = "ACCEPT KEY: " + SaveData.settings.gamepadBinds[4].toString();
					case 5:
						text1.text = "EXIT KEY: " + SaveData.settings.gamepadBinds[5].toString();
				}

				if (inChange) {
					var keyPressed:FlxGamepadInputID = gamepad.firstJustPressedID();
					if (!Input.gamepadIs('gamepad_accept') && !Input.gamepadIs('gamepad_exit') && gamepad.anyJustPressed([ANY])
						&& keyPressed.toString() != FlxGamepadInputID.NONE) {
						switch (init) {
							case 0:
								SaveData.settings.gamepadBinds[0] = keyPressed;
								Input.controllerMap.set("gamepad_left", SaveData.settings.gamepadBinds[0]);
							case 1:
								SaveData.settings.gamepadBinds[1] = keyPressed;
								Input.controllerMap.set("gamepad_down", SaveData.settings.gamepadBinds[1]);
							case 2:
								SaveData.settings.gamepadBinds[2] = keyPressed;
								Input.controllerMap.set("gamepad_up", SaveData.settings.gamepadBinds[2]);
							case 3:
								SaveData.settings.gamepadBinds[3] = keyPressed;
								Input.controllerMap.set("gamepad_right", SaveData.settings.gamepadBinds[3]);
							case 4:
								SaveData.settings.gamepadBinds[4] = keyPressed;
								Input.controllerMap.set("gamepad_accept", SaveData.settings.gamepadBinds[4]);
							case 5:
								SaveData.settings.gamepadBinds[5] = keyPressed;
								Input.controllerMap.set("gamepad_exit", SaveData.settings.gamepadBinds[5]);
						}
						FlxG.sound.play(Paths.sound('scroll'));
						text2.text = "";
						inChange = false;
					}
				}
			}
		}
	}
}