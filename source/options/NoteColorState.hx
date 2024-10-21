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

    override function create() {
        super.create();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
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

		daText = new FlxText(0, 280, FlxG.width, "Use LEFT/RIGHT to change the selected arrow or the selected color.\nUse ENTER to select a note.\nUse RESET to reset a note's color.", 12);
		daText.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		daText.screenCenter(X);
		add(daText);
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

        if (Input.justPressed('exit')) {
			if (isSelectingSomething)
				isSelectingSomething = false;
			else {
            	SaveData.saveSettings();
				ExtendableState.switchState(new OptionsState());
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
		}

		for (note in strumline) {
			if (note.ID == curSelectedControl && Input.justPressed('accept') && !isSelectingSomething) {
				curSelectedControl = note.ID;
				isSelectingSomething = true;
			}
			note.alpha = (note.ID == curSelectedControl) ? 1 : 0.6;
		}
	}
}