package options;

// not much functionality yet until i actually do some stuff idk
class ControlsSubState extends ExtendableSubState {
	var keyArray:Array<Array<FlxKey>> = [];
	var btnArray:Array<Array<FlxGamepadInputID>> = [];

	var coolControls:Array<String> = [];

	var ctrlGroup:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var camFollow:FlxObject;
	var isChangingBind:Bool = false;
	var gamepadMode:Bool = false;

	var anyKeyTxt:FlxText;

	var bg:FlxSprite;

	public function new() {
		super();

		keyArray = SaveData.settings.keyboardBinds;
		btnArray = SaveData.settings.gamepadBinds;

		coolControls = [
			"Left: " + keyArray[0][0].toString(),
			"Left (Alt): " + keyArray[0][1].toString(),
			"Down: " + keyArray[1][0].toString(),
			"Down (Alt): " + keyArray[1][1].toString(),
			"Up: " + keyArray[2][0].toString(),
			"Up (Alt): " + keyArray[2][1].toString(),
			"Right: " + keyArray[3][0].toString(),
			"Right (Alt): " + keyArray[3][1].toString(),
			"Accept: " + keyArray[4][0].toString(),
			"Exit: " + keyArray[5][0].toString(),
			"Restart: " + keyArray[6][0].toString()
		];

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
		anyKeyTxt.screenCenter();
		add(anyKeyTxt);

		changeSelection(0, false);

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		// if (!isChangingBind) {
		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		/* if (Input.justPressed('accept')) {
			isChangingBind = true;
			anyKeyTxt.text = "PRESS ANY KEY TO CONTINUE";
		}*/

		if (Input.justPressed('exit')) {
			persistentDraw = persistentUpdate = true;
			close();
		}
		// }

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		/*
			if (isChangingBind) {
				if (Input.justPressed('any')) {
					if (gamepadMode) {
						var keyPressed:FlxGamepadInputID = gamepad.firstJustPressedID();
						if (gamepad != null && gamepad.anyJustPressed([ANY]) && keyPressed.toString() != NONE) {
							// nothing yet
						}
					} else {
						// nothing yet
					}
					FlxG.sound.play(Paths.sound('select'));
					isChangingBind = false;
				}
			}
		 */
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

	function regenList() {}

	function updateCtrlList() {}
}