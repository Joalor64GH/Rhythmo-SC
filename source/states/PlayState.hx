package states;

class PlayState extends FlxState {
	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];
	var strumline:FlxTypedGroup<Note>;
	var notes:FlxTypedGroup<Note>;

	var scoreTxt:FlxText;

	override function create() {
		super.create();

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(i * 40, 50, noteDirs[i], "receptor");
			strumline.add(note);
		}

		notes = new FlxTypedGroup<Note>();
        add(notes);

		new FlxTimer().start(1, () -> {
			spawnNote();
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		for (note in notes.members) {
            note.update(elapsed);

            switch (note.dir) {
                case "left":
                    if (FlxG.keys.justPressed.LEFT && note.y >= FlxG.height - 150 && note.y <= FlxG.height - 50) {
                        note.press();
                        notes.remove(note, true);
                    }
                case "down":
                    if (FlxG.keys.justPressed.DOWN && note.y >= FlxG.height - 150 && note.y <= FlxG.height - 50) {
                        note.press();
                        notes.remove(note, true);
                    }
                case "up":
                    if (FlxG.keys.justPressed.UP && note.y >= FlxG.height - 150 && note.y <= FlxG.height - 50) {
                        note.press();
                        notes.remove(note, true);
                    }
                case "right":
                    if (FlxG.keys.justPressed.RIGHT && note.y >= FlxG.height - 150 && note.y <= FlxG.height - 50) {
                        note.press();
                        notes.remove(note, true);
                    }
            }

            if (note.y > FlxG.height)
                notes.remove(note, true);
        }
	}

	private function spawnNote(timer:FlxTimer):Void {
        var randomIndex = FlxG.random.int(0, noteDirs.length - 1);
        var note:Note = new Note(randomIndex * 60 + 100, 0, noteDirs[randomIndex], "note");
        notes.add(note);
    }
}