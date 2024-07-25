package states;

import game.Song.SongData;

class PlayState extends ExtendableState {
	public static var instance:PlayState;
	public static var songMultiplier:Float = 1;

	public var speed:Float = 1;
	public var song:SongData;
	
	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];
	var strumline:FlxTypedGroup<Note>;
	var notes:FlxTypedGroup<Note>;

	var spawnNotes:Array<Note> = [];

	var ratings:FlxTypedGroup<Rating>;

	var score:Int = 0;
	var scoreTxt:FlxText;
	var timeBar:Bar;

	override public function new() {
		super();

		if (song == null) {
			song = {
				song: "Test",
				notes: [],
				bpm: 100,
				timeSignature: [4, 4]
			};
		}

		instance = this;
	}

	override function create() {
		super.create();

		if (songMultiplier < 0.1) songMultiplier = 0.1;

		Conductor.changeBPM(song.bpm, songMultiplier);
		Conductor.recalculateStuff(songMultiplier);
		Conductor.safeZoneOffset *= songMultiplier;

		resetSongPos();

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteWidth:Float = 150;
		var totalWidth:Float = noteDirs.length * noteWidth;
		var startX:Float = (FlxG.width - totalWidth) / 2;

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(startX + i * noteWidth, 50, noteDirs[i], "receptor");
			strumline.add(note);
		}

		timeBar = new Bar(0, 0, FlxG.width, 10, FlxColor.WHITE, FlxColor.fromRGB(30, 144, 255));
		timeBar.screenCenter(X);
		timeBar.y = FlxG.height + 10;
		add(timeBar);
	}

	function resetSongPos()
	{
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
		timeBar.value = 0;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing) {
			Conductor.songPosition = FlxG.sound.music.time;
			timeBar.value = (Conductor.songPosition / FlxG.sound.music.length);
		}
		else
			Conductor.songPosition += (FlxG.elapsed) * 1000;

		if (spawnNotes[0] != null) {
			while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * songMultiplier)) {
				var dunceNote:Note = spawnNotes[0];
				notes.add(dunceNote);

				var index:Int = spawnNotes.indexOf(dunceNote);
				spawnNotes.splice(index, 1);
			}
		}

		for (note in notes) {
			var strum = strumline.members[note.dir % 4];

			note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

			if (Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null) {
				notes.remove(note);
				note.kill();
				note.destroy();
			}
		}

		if (Input.is("exit"))
			FlxG.switchState(MenuState.new);

		// TO-DO: better input system
		strumline.forEach((spr:Note) -> {
			switch (spr.dir) {
				case "left":
					if (Input.is("left", PRESSED)) spr.press(); else spr.animation.play("receptor");
				case "down":
					if (Input.is("down", PRESSED)) spr.press(); else spr.animation.play("receptor");
				case "up":
					if (Input.is("up", PRESSED)) spr.press(); else spr.animation.play("receptor");
				case "right":
					if (Input.is("right", PRESSED)) spr.press(); else spr.animation.play("receptor");
			}
		});
	}
}