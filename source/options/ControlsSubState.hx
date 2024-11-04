package options;

class ControlsSubState extends ExtendableSubState {
	var coolControls:Array<String> = [
		"Left", "Down", "Up", "Right", "Left (Alt)", "Down (Alt)", "Up (Alt)", "Right (Alt)", "Accept", "Exit", "Restart"
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

	var tempBG:FlxSprite;

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

		curControl = new FlxText(700, 0, 0, "", 12);
		curControl.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curControl.scrollFactor.set();
		curControl.screenCenter(Y);
		add(curControl);

		switchSpr = new FlxSprite(5, FlxG.height - 44).makeGraphic(50, 50, FlxColor.BLACK); // placeholder for now
		switchSpr.scrollFactor.set();
		add(switchSpr);

		tempBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		tempBG.scrollFactor.set();
		tempBG.screenCenter();
		tempBG.alpha = 0.65;
		tempBG.visible = false;
		add(tempBG);

		anyKeyTxt = new FlxText(0, 0, 0, "", 12);
		anyKeyTxt.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		anyKeyTxt.scrollFactor.set();
		anyKeyTxt.screenCenter(XY);
		add(anyKeyTxt);

		changeSelection(0, false);

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (gamepadMode)
			curControl.text = FlxGamepadInputID.toStringMap.get(SaveData.settings.gamepadBinds[curSelected]);
		else
			curControl.text = FlxGamepadInputID.toStringMap.get(SaveData.settings.keyboardBinds[curSelected]);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!isChangingBind) {
			if (Input.justPressed('up') || Input.justPressed('down'))
				changeSelection(Input.justPressed('up') ? -1 : 1);

			if (Input.justPressed('accept')) {
				isChangingBind = true;
				tempBG.visible = true;
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
					if (gamepad != null && keyPressed.toString() != FlxGamepadInputID.NONE) {
						SaveData.settings.gamepadBinds[curSelected] = keyPressed;
					}
				} else {
					SaveData.settings.keyboardBinds[curSelected] = FlxG.keys.getIsDown()[0].ID.toString();
				}
				SaveData.saveSettings();
				Input.refreshControls();
				FlxG.sound.play(Paths.sound('select'));
				isChangingBind = false;
				anyKeyTxt.text = "";
				tempBG.visible = false;
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