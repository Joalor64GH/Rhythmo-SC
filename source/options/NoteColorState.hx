package options;

class NoteColorState extends ExtendableState {
	var daText:FlxText;

	var strumline:FlxTypedGroup<Note>;
	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];

	var isSelectingSomething:Bool = false;
	var curSelectedControl:Int = 0;

	var curSelectedValue:Int = 0; // red - 0, green - 1, blue - 2
	var curColorVals:Array<Int> = [255, 0, 0];

	final colorMins:Array<Int> = [0, 0, 0];
	final colorMaxs:Array<Int> = [255, 255, 255];

	var fromPlayState:Bool = false;

	public function new(?fromPlayState:Bool = false) {
		super();
		this.fromPlayState = fromPlayState;
	}

	override function create() {
		super.create();

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		var noteWidth:Float = 200;
		var totalWidth:Float = noteDirs.length * noteWidth;
		var startX:Float = (FlxG.width - totalWidth) / 2;

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(startX + i * noteWidth, 50, noteDirs[i], "note");
			note.ID = i;
			strumline.add(note);
		}

		daText = new FlxText(0, 280, FlxG.width, "", 12);
		daText.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		daText.screenCenter(X);
		add(daText);

		updateColorVals();
		updateText();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('reset')) {
			curColorVals = NoteColors.defaultColors[curSelectedControl];

			strumline.members[curSelectedControl].colorSwap.r = curColorVals[0];
			strumline.members[curSelectedControl].colorSwap.g = curColorVals[1];
			strumline.members[curSelectedControl].colorSwap.b = curColorVals[2];

			NoteColors.setNoteColor(curSelectedControl, curColorVals);
		}

		if (Input.justPressed('exit')) {
			if (isSelectingSomething)
				isSelectingSomething = false;
			else {
				SaveData.saveSettings();
				ExtendableState.switchState(new OptionsState(fromPlayState));
				FlxG.sound.play(Paths.sound('cancel'));
			}
		}

		if (!isSelectingSomething && (Input.justPressed('left') || Input.justPressed('right'))) {
			if (Input.justPressed('left'))
				curSelectedControl--;
			if (Input.justPressed('right'))
				curSelectedControl++;

			if (curSelectedControl < 0)
				curSelectedControl = 3;
			if (curSelectedControl > 3)
				curSelectedControl = 0;

			updateColorVals();
		}

		if (isSelectingSomething && (Input.justPressed('up') || Input.justPressed('down'))) {
			if (Input.justPressed('up'))
				curColorVals[curSelectedValue]++;
			if (Input.justPressed('down'))
				curColorVals[curSelectedValue]--;

			if (curColorVals[curSelectedValue] < colorMins[curSelectedValue])
				curColorVals[curSelectedValue] = colorMins[curSelectedValue];
			if (curColorVals[curSelectedValue] > colorMaxs[curSelectedValue])
				curColorVals[curSelectedValue] = colorMaxs[curSelectedValue];

			switch (curSelectedValue) {
				case 0:
					strumline.members[curSelectedControl].colorSwap.r = curColorVals[curSelectedValue];
				case 1:
					strumline.members[curSelectedControl].colorSwap.g = curColorVals[curSelectedValue];
				case 2:
					strumline.members[curSelectedControl].colorSwap.b = curColorVals[curSelectedValue];
			}

			NoteColors.setNoteColor(curSelectedControl, curColorVals);
		}

		if (isSelectingSomething && (Input.justPressed('left') || Input.justPressed('right'))) {
			if (Input.justPressed('left'))
				curSelectedValue--;
			if (Input.justPressed('right'))
				curSelectedValue++;

			if (curSelectedValue < 0)
				curSelectedValue = 2;
			if (curSelectedValue > 2)
				curSelectedValue = 0;
		}

		updateText();

		for (note in strumline) {
			if (note.ID == curSelectedControl && Input.justPressed('accept') && !isSelectingSomething) {
				curSelectedControl = note.ID;
				isSelectingSomething = true;
			}
			note.alpha = (note.ID == curSelectedControl) ? 1 : 0.6;
		}
	}

	function updateText() {
		var red:String = Std.string(curColorVals[0]);
		var green:String = Std.string(curColorVals[1]);
		var blue:String = Std.string(curColorVals[2]);

		switch (curSelectedValue) {
			case 0:
				red = '>$red<';
			case 1:
				green = '>$green<';
			case 2:
				blue = '>$blue<';
		}

		daText.text = Localization.get("noteColorGuide")
			+ Localization.get("red")
			+ red
			+ Localization.get("green")
			+ green
			+ Localization.get("blue")
			+ blue;
		daText.screenCenter(X);
	}

	inline function updateColorVals() {
		curColorVals = NoteColors.getNoteColor(curSelectedControl);
	}
}