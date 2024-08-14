package states;

import game.Song.SongData;

class PlayState extends ExtendableState {
	public static var instance:PlayState;
	public static var song:SongData;

	public static var songMultiplier:Float = 1;
	public static var chartingMode:Bool = false;

	public var speed:Float = 1;

	private var scriptArray:Array<Hscript> = [];

	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];
	var strumline:FlxTypedGroup<Note>;
	var notes:FlxTypedGroup<Note>;
	var spawnNotes:Array<Note> = [];

	var ratingDisplay:Rating;

	var score:Int = 0;
	var combo:Int = 0;
	var misses:Int = 0;
	var scoreTxt:FlxText;
	var timeBar:Bar;

	var camZooming:Bool = false;

	var paused:Bool = false;
	var canPause:Bool = true;

	var startingSong:Bool = false;
	var startedCountdown:Bool = false;

	var countdown3:FlxSprite;
	var countdown2:FlxSprite;
	var countdown1:FlxSprite;
	var go:FlxSprite;

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
			song = Song.loadSongfromJson(Paths.formatToSongPath(song.song));

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
		Conductor.songPosition = 0;

		generateNotes();

		speed = SaveData.settings.songSpeed;
		speed /= songMultiplier;
		if (speed < 0.1 && songMultiplier > 1)
			speed = 0.1;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/bg'));
		bg.screenCenter(XY);
		add(bg);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteWidth:Float = 200;
		var totalWidth:Float = noteDirs.length * noteWidth;
		var startX:Float = (FlxG.width - totalWidth) / 2;
		var noteY:Float = (SaveData.settings.downScroll) ? FlxG.height - 150 : 50;

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(startX + i * noteWidth, noteY, noteDirs[i], "receptor");
			strumline.add(note);
		}

		for (script in Assets.list(TEXT).filter(text -> text.contains('assets/scripts')))
			if (script.endsWith('.hxs'))
				scriptArray.push(new Hscript(script));

		timeBar = new Bar(0, 0, FlxG.width, 10, FlxColor.WHITE, FlxColor.fromRGB(30, 144, 255));
		timeBar.screenCenter(X);
		timeBar.y = FlxG.height - 20;
		add(timeBar);

		scoreTxt = new FlxText(0, (FlxG.height * 0.89) + 20, FlxG.height, "Score: 0 // Misses: 0", 20);
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.screenCenter(X);
		add(scoreTxt);

		var ratingDisplayYPos:Float = 80;

		if (!SaveData.settings.downScroll)
			ratingDisplayYPos = FlxG.height - 180;

		ratingDisplayYPos -= 20;

		ratingDisplay = new Rating(0, 0);
		ratingDisplay.screenCenter();
		ratingDisplay.alpha = 0;
		add(ratingDisplay);

		countdown3 = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/three'));
		countdown3.antialiasing = SaveData.settings.antialiasing;
		countdown3.screenCenter();
		countdown3.visible = false;
		add(countdown3);

		countdown2 = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/two'));
		countdown2.antialiasing = SaveData.settings.antialiasing;
		countdown2.screenCenter();
		countdown2.visible = false;
		add(countdown2);

		countdown1 = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/one'));
		countdown1.antialiasing = SaveData.settings.antialiasing;
		countdown1.screenCenter();
		countdown1.visible = false;
		add(countdown1);

		go = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/go'));
		go.antialiasing = SaveData.settings.antialiasing;
		go.screenCenter();
		go.visible = false;
		add(go);

		if (Assets.exists(Paths.script('songs/' + Paths.formatToSongPath(song.song) + '/script')))
			scriptArray.push(new Hscript(Paths.script('songs/' + Paths.formatToSongPath(song.song) + '/script')));

		startingSong = true;
		startCountdown();
	}

	function resetSongPos() {
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
	}

	function startCountdown() {
		if (startedCountdown) {
			callOnScripts('startCountdown', []);
			return;
		}

		var ret:Dynamic = callOnScripts('startCountdown', []);
		if (ret != Hscript.Function_Stop) {
			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			countdown3.visible = true;
			FlxG.sound.play(Paths.sound('wis_short'));
			FlxTween.tween(countdown3, {alpha: 0}, Conductor.crochet / 1000, {
				onComplete: (twn:FlxTween) -> {
					countdown3.visible = false;
					countdown2.visible = true;
					FlxG.sound.play(Paths.sound('wis_short'));
					FlxTween.tween(countdown2, {alpha: 0}, Conductor.crochet / 1000, {
						onComplete: (twn:FlxTween) -> {
							countdown2.visible = false;
							countdown1.visible = true;
							FlxG.sound.play(Paths.sound('wis_short'));
							FlxTween.tween(countdown1, {alpha: 0}, Conductor.crochet / 1000, {
								onComplete: (twn:FlxTween) -> {
									countdown1.visible = false;
									go.visible = true;
									FlxG.sound.play(Paths.sound('wis_long'));
									FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
										onComplete: (twn:FlxTween) -> {
											go.visible = false;
										}
									});
								}
							});
						}
					});
				}
			});
		}
	}

	function startSong() {
		startingSong = false;

		FlxG.sound.playMusic(Paths.song(Paths.formatToSongPath(song.song)), 1, false);
		FlxG.sound.music.onComplete = () -> endSong();

		if (paused && FlxG.sound.music != null)
			FlxG.sound.music.pause();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		callOnScripts('update', [elapsed]);

		if (startedCountdown)
			Conductor.songPosition += elapsed * 1000;

		if (startingSong) {
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if (!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		} else {
			if (!paused && FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing) {
				Conductor.songPosition = FlxG.sound.music.time;
				timeBar.value = (Conductor.songPosition / FlxG.sound.music.length);
			}
		}

		camZooming = (FlxG.sound.music.playing) ? true : false;

		scoreTxt.text = 'Score: $score // Misses: $misses';

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

			if (SaveData.settings.downScroll)
				note.y = strum.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			else
				note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

			if (Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null) {
				combo = 0;
				misses++;
				notes.remove(note);
				note.kill();
				note.destroy();
			}
		}

		if (Input.is("exit") && canPause && startedCountdown)
			pause();

		if (Input.is("seven")) {
			ExtendableState.switchState(new ChartingState());
			ChartingState.instance.song = song;
			chartingMode = true;
		}

		inputFunction();
	}

	var lastStepHit:Int = -1;
	var lastBeatHit:Int = -1;

	override function stepHit() {
		super.stepHit();

		if (curStep == lastStepHit)
			return;

		lastStepHit = curStep;
		callOnScripts('stepHit', [curStep]);
	}

	override function beatHit() {
		super.beatHit();

		if (lastBeatHit >= curBeat)
			return;

		if (camZooming)
			if (curBeat % (song.timeSignature[0] / 2) == 0)
				FlxTween.tween(FlxG.camera, {zoom: 1.03}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

		lastBeatHit = curBeat;
		callOnScripts('beatHit', [curBeat]);
	}

	override function openSubState(SubState:FlxSubState) {
		paused = true;
		FlxG.sound.music.pause();
		super.openSubState(SubState);
	}

	override function closeSubState() {
		paused = false;
		callOnScripts('resume', []);
		FlxG.sound.music.resume();
		super.closeSubState();
	}

	function pause() {
		var ret:Dynamic = callOnScripts('pause', []);
		if (ret != Hscript.Function_Stop) {
			openSubState(new PauseSubState());
			persistentUpdate = false;
			persistentDraw = true;
		}
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

					switch (curRating) {
						case "perfect":
							score += ratingScores[0];
						case "nice":
							score += ratingScores[1];
						case "okay":
							score += ratingScores[2];
						case "no":
							score += ratingScores[3];
					}

					ratingDisplay.showCurrentRating();
					ratingDisplay.screenCenter(X);

					combo++;

					var comboSplit:Array<String> = Std.string(combo).split('');
					var seperatedScore:Array<Int> = [];
					for (i in 0...comboSplit.length)
						seperatedScore.push(Std.parseInt(comboSplit[i]));

					var daLoop:Int = 0;

					for (i in seperatedScore) {
						var numScore:FlxSprite = new FlxSprite(0, 0);
						numScore.loadGraphic(Paths.image('ui/num' + Std.int(i)));
						numScore.scale.set(0.5, 0.5);
						numScore.screenCenter();
						numScore.x = (FlxG.width * 0.65) + (60 * daLoop) - 160;
						numScore.y = ratingDisplay.y + 120;
						numScore.acceleration.y = FlxG.random.int(200, 300);
						numScore.velocity.y -= FlxG.random.int(140, 160);
						numScore.velocity.x = FlxG.random.float(-5, 5);
						insert(members.indexOf(strumline), numScore);

						FlxTween.tween(numScore, {alpha: 0}, 0.2, {
							onComplete: (twn:FlxTween) -> {
								numScore.destroy();
							},
							startDelay: 1
						});

						daLoop++;
					}

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
		var ret:Dynamic = callOnScripts('endSong', []);
		if (ret != Hscript.Function_Stop) {
			if (chartingMode) {
				ExtendableState.switchState(new ChartingState());
				ChartingState.instance.song = song;
				return false;
			}
			ExtendableState.switchState(new SongSelectState());
			FlxG.sound.playMusic(Paths.sound('Basically_Professionally_Musically', true), 0.75);
			HighScore.saveScore(song.song, score);
			canPause = false;
		}
		return true;
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

	override function destroy() {
		scriptArray = [];
		callOnScripts('destroy', []);

		instance = null;

		super.destroy();
	}

	private function callOnScripts(funcName:String, args:Array<Dynamic>):Dynamic {
		var value:Dynamic = Hscript.Function_Continue;

		for (i in 0...scriptArray.length) {
			final call:Dynamic = scriptArray[i].executeFunc(funcName, args);
			final bool:Bool = call == Hscript.Function_Continue;
			if (!bool && call != null)
				value = call;
		}

		return value;
	}
}