package states;

import game.Song.SongData;

// to-do: maybe add a countdown??
class PlayState extends ExtendableState {
	public static var instance:PlayState;
	public static var songMultiplier:Float = 1;

	public var speed:Float = 1;
	public var song:SongData;

	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];
	var strumline:FlxTypedGroup<Note>;
	var notes:FlxTypedGroup<Note>;

	var spawnNotes:Array<Note> = [];

	var ratingDisplay:Rating;

	var score:Int = 0;
	var misses:Int = 0;
	var scoreTxt:FlxText;
	var timeBar:Bar;

	var paused:Bool = false;

	override public function new() {
		super();

		if (song == null) {
			song = {
				song: "Test",
				notes: [],
				bpm: 100,
				timeSignature: [4, 4]
			};
		} else
			song = Json.parse(Paths.file("songs/" + song.song.toLowerCase() + "chart.json"));

		instance = this;
	}

	override function create() {
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (songMultiplier < 0.1)
			songMultiplier = 0.1;

		Conductor.changeBPM(song.bpm, songMultiplier);
		Conductor.recalculateStuff(songMultiplier);
		Conductor.safeZoneOffset *= songMultiplier;

		resetSongPos();

		var tempBG:FlxSprite = FlxGridOverlay.create(50, 50);
		tempBG.screenCenter(XY);
		add(tempBG);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteWidth:Float = 200;
		var totalWidth:Float = noteDirs.length * noteWidth;
		var startX:Float = (FlxG.width - totalWidth) / 2;

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(startX + i * noteWidth, 50, noteDirs[i], "receptor");
			strumline.add(note);
		}

		scoreTxt = new FlxText(0, (FlxG.height * 0.89) + 36, FlxG.height, "Score: 0 // Misses: 0", 20);
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.screenCenter(X);
		add(scoreTxt);

		timeBar = new Bar(0, 0, FlxG.width, 10, FlxColor.WHITE, FlxColor.fromRGB(30, 144, 255));
		timeBar.screenCenter(X);
		timeBar.y = FlxG.height + 10;
		add(timeBar);

		ratingDisplay = new Rating(0, 0);
		ratingDisplay.screenCenter();
		ratingDisplay.alpha = 0;
		add(ratingDisplay);

		if (!paused)
			FlxG.sound.playMusic(Paths.song(song.song.toLowerCase()), 1, false);
		FlxG.sound.music.onComplete = () -> endSong();

		generateNotes();
	}

	function resetSongPos() {
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		scoreTxt.text = 'Score: $score // Misses: $misses';

		if (FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing) {
			Conductor.songPosition = FlxG.sound.music.time;
			timeBar.value = (Conductor.songPosition / FlxG.sound.music.length);
		} else
			Conductor.songPosition += (FlxG.elapsed) * 1000;

		if (spawnNotes.length > 0) {
			while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * songMultiplier)) {
				var dunceNote:Note = spawnNotes[0];
				notes.add(dunceNote);

				var index:Int = spawnNotes.indexOf(dunceNote);
				spawnNotes.splice(index, 1);
			}
		}

		for (note in notes) {
			var strum = strumline.members[getNoteIndex(note.dir)];

			note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

			if (Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null) {
				misses++;
				notes.remove(note);
				note.kill();
				note.destroy();
			}
		}

		if (Input.is("exit")) {
			openSubState(new PauseSubState());
			persistentUpdate = false;
			paused = true;
		}

		if (Input.is("seven")) {
			ExtendableState.switchState(new ChartingState());
			ChartingState.instance.song = song;
		}

		inputFunction();
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused)
			FlxG.sound.music.pause();

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			FlxG.sound.music.resume();
			paused = false;
		}

		super.closeSubState();
	}

	public var curRating:String = "perfect";

	function inputFunction() {
		var justPressed:Array<Bool> = [Input.is("left"), Input.is("down"), Input.is("up"), Input.is("right")];
		var pressed:Array<Bool> = [
			Input.is("left", PRESSED),
			Input.is("down", PRESSED),
			Input.is("up", PRESSED),
			Input.is("right", PRESSED)
		];
		var released:Array<Bool> = [
			Input.is("left", RELEASED),
			Input.is("down", RELEASED),
			Input.is("up", RELEASED),
			Input.is("right", RELEASED)
		];

		for (i in 0...justPressed.length)
			if (justPressed[i])
				strumline.members[i].press();

		for (i in 0...released.length)
			if (released[i])
				strumline.members[i].animation.play("receptor");

		var possibleNotes:Array<Note> = [];

		for (note in notes) {
			note.calculateCanBeHit();
			if (note.canBeHit && !note.tooLate)
				possibleNotes.push(note);
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		var doNotHit:Array<Bool> = [false, false, false, false];
		var noteDataTimes:Array<Float> = [-1, -1, -1, -1];

		if (possibleNotes.length > 0) {
			for (i in 0...possibleNotes.length) {
				var note = possibleNotes[i];

				if ((justPressed[getNoteIndex(note.dir)] && !doNotHit[getNoteIndex(note.dir)])) {
					var ratingScores:Array<Int> = [350, 200, 100, 50];

					var noteMs = (Conductor.songPosition - note.strum) / songMultiplier;

					var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);

					curRating = "perfect";

					if (Math.abs(noteMs) > 22.5)
						curRating = 'perfect';

					if (Math.abs(noteMs) > 45)
						curRating = 'nice';

					if (Math.abs(noteMs) > 90)
						curRating = 'okay';

					if (Math.abs(noteMs) > 135)
						curRating = 'no';

					noteDataTimes[getNoteIndex(note.dir)] = note.strum;
					doNotHit[getNoteIndex(note.dir)] = true;

					strumline.members[getNoteIndex(note.dir)].press();

					ratingDisplay.showCurrentRating();
					ratingDisplay.screenCenter(X);

					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}

			if (possibleNotes.length > 0) {
				for (i in 0...possibleNotes.length) {
					var note = possibleNotes[i];

					if (note.strum == noteDataTimes[getNoteIndex(note.dir)] && doNotHit[getNoteIndex(note.dir)]) {
						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}
	}

	function endSong() {
		ExtendableState.switchState(new MenuState());
		// FlxG.sound.playMusic(Paths.music('Rhythmic_Odyssey'));
		// HighScore.saveScore(song, score);
		// HighScore.saveScoresToFile();
	}

	function generateNotes() {
		for (section in song.notes) {
			Conductor.recalculateStuff(songMultiplier);

			for (note in section.sectionNotes) {
				var strum = strumline.members[note.noteData % noteDirs.length];

				var daStrumTime:Float = note.noteStrum + 1 * songMultiplier;
				var daNoteData:Int = Std.int(note.noteData % noteDirs.length);

				var oldNote:Note;

				if (spawnNotes.length > 0)
					oldNote = spawnNotes[Std.int(spawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(strum.x, strum.y, noteDirs[daNoteData], "note");
				swagNote.scrollFactor.set();
				swagNote.lastNote = oldNote;
				swagNote.strum = daStrumTime;
				swagNote.animation.play('note');

				spawnNotes.push(swagNote);
			}
		}

		spawnNotes.sort(sortStuff);
	}

	function sortStuff(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);

	function getNoteIndex(direction:String):Int {
		return switch (direction) {
			case "left": 0;
			case "down": 1;
			case "up": 2;
			case "right": 3;
			default: -1;
		}
	}
}