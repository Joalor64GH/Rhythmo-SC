package options;

class OptionsState extends ExtendableState {
	final options:Array<String> = ['Preferences', 'Controls', 'Language', 'Note Colors'];
	var opGrp:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		opGrp = new FlxTypedGroup<FlxText>();
		add(opGrp);

		for (i in 0...options.length) {
			var text:FlxText = new FlxText(0, 260 + (i * 70), 0, options[i], 32);
			text.setFormat(Paths.font('vcr.ttf'), 80, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.screenCenter(X);
			text.ID = i;
			opGrp.add(text);
		}

		changeSelection(0, false);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		if (Input.justPressed('accept')) {
			switch (curSelected) {
				case 0:
					openSubState(new options.OptionsSubState());
					persistentUpdate = persistentDraw = false;
				case 1:
					openSubState(new options.ControlsSubState());
					persistentUpdate = persistentDraw = false;
				case 2:
					ExtendableState.switchState(new options.LanguageState());
				case 3:
					ExtendableState.switchState(new options.NoteColorState());
			}
		}

		if (Input.justPressed('exit')) {
			if (PauseSubState.fromPlayState) {
				ExtendableState.switchState(new PlayState());
				PauseSubState.fromPlayState = false;
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
			} else
				ExtendableState.switchState(new MenuState());
			FlxG.sound.play(Paths.sound('cancel'));
		}
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		opGrp.forEach(function(txt:FlxText) {
			txt.color = (txt.ID == curSelected) ? FlxColor.LIME : FlxColor.WHITE;
		});
	}
}