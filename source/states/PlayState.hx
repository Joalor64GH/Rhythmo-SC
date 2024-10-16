package states;

import backend.Song.SongData;

class PlayState extends ExtendableState {
	public static var instance:PlayState = null;
	public static var song:SongData = null;
	public static var songMultiplier:Float = 1;
	public static var chartingMode:Bool = false;
	public static var gotAchievement:Bool = false;

	public var speed:Float = 1;

	public var ratingDisplay:Rating;
	public var score:Int = 0;
	public var combo:Int = 0;
	public var misses:Int = 0;
	public var scoreTxt:FlxText;

	public var timeBar:Bar;
	private var timeTxt:FlxText;
	private var updateTime:Bool = true;

	public var judgementCounter:FlxText;
	public var perfects:Int = 0;
	public var nices:Int = 0;
	public var okays:Int = 0;
	public var nos:Int = 0;

	public var scriptArray:Array<Hscript> = [];

	public var noteSplashes:FlxTypedGroup<NoteSplash>;
	public var strumline:FlxTypedGroup<Note>;
	public var notes:FlxTypedGroup<Note>;
	public var spawnNotes:Array<Note> = [];

	public var camZooming:Bool = true;
	public var paused:Bool = false;
	public var startingSong:Bool = false;

	public var countdown3:FlxSprite;
	public var countdown2:FlxSprite;
	public var countdown1:FlxSprite;
	public var go:FlxSprite;

	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];

	var canPause:Bool = true;
	var startedCountdown:Bool = false;
	var isPerfect:Bool = true;

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
		FlxG.mouse.visible = false;
	}

	override function create() {
		super.create();

		Paths.clearStoredMemory();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		persistentUpdate = persistentDraw = true;

		if (songMultiplier < 0.1)
			songMultiplier = 0.1;

		speed = SaveData.settings.songSpeed;
		speed /= songMultiplier;
		if (speed < 0.1 && songMultiplier > 1)
			speed = 0.1;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/bg'));
		add(bg);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		noteSplashes = new FlxTypedGroup<NoteSplash>();
		add(noteSplashes);

		var noteWidth:Float = 200;
		var totalWidth:Float = noteDirs.length * noteWidth;
		var startX:Float = (FlxG.width - totalWidth) / 2;
		var noteY:Float = (SaveData.settings.downScroll) ? FlxG.height - 250 : 50;

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(startX + i * noteWidth, noteY, noteDirs[i], "receptor");
			strumline.add(note);
		}

		var foldersToCheck:Array<String> = [Paths.file('scripts/')];
		#if FUTURE_POLYMOD
		for (mod in ModHandler.getMods())
			foldersToCheck.push('mods/' + mod + '/scripts/');
		#end
		for (folder in foldersToCheck) {
			if (FileSystem.exists(folder) && FileSystem.isDirectory(folder)) {
				for (file in FileSystem.readDirectory(folder)) {
					if (file.endsWith('.hxs')) {
						scriptArray.push(new Hscript(folder + file));
					}
				}
			}
		}

		scoreTxt = new FlxText(0, (FlxG.height * (SaveData.settings.downScroll ? 0.11 : 0.89)) + 20, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.screenCenter(X);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.screenCenter(Y);
		add(judgementCounter);

		timeBar = new Bar(0, 0, FlxG.width, 10, FlxColor.WHITE, FlxColor.fromRGB(30, 144, 255));
		timeBar.screenCenter(X);
		timeBar.y = (SaveData.settings.downScroll) ? scoreTxt.y : FlxG.height - 20;
		add(timeBar);
		add(scoreTxt);

		timeTxt = new FlxText(20, timeBar.y, 0, "[-:--/-:--]", 20);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(timeTxt);

		var ratingDisplayYPos:Float = 80;

		if (!SaveData.settings.downScroll)
			ratingDisplayYPos = FlxG.height - 180;

		ratingDisplayYPos -= 20;

		ratingDisplay = new Rating(0, 0);
		ratingDisplay.screenCenter();
		ratingDisplay.alpha = 0;
		add(ratingDisplay);

		countdown3 = new FlxSprite(0, 0).loadGraphic(Paths.image('gameplay/three'));
		countdown3.antialiasing = SaveData.settings.antialiasing;
		countdown3.screenCenter();
		countdown3.visible = false;
		add(countdown3);

		countdown2 = new FlxSprite(0, 0).loadGraphic(Paths.image('gameplay/two'));
		countdown2.antialiasing = SaveData.settings.antialiasing;
		countdown2.screenCenter();
		countdown2.visible = false;
		add(countdown2);

		countdown1 = new FlxSprite(0, 0).loadGraphic(Paths.image('gameplay/one'));
		countdown1.antialiasing = SaveData.settings.antialiasing;
		countdown1.screenCenter();
		countdown1.visible = false;
		add(countdown1);

		go = new FlxSprite(0, 0).loadGraphic(Paths.image('gameplay/go'));
		go.antialiasing = SaveData.settings.antialiasing;
		go.screenCenter();
		go.visible = false;
		add(go);

		generateSong();

		var foldersToCheck:Array<String> = [Paths.file('songs/' + Paths.formatToSongPath(song.song) + '/')];
		#if FUTURE_POLYMOD
		for (mod in ModHandler.getMods())
			foldersToCheck.push('mods/' + mod + '/songs/' + Paths.formatToSongPath(song.song) + '/');
		#end
		for (folder in foldersToCheck) {
			if (FileSystem.exists(folder) && FileSystem.isDirectory(folder)) {
				for (file in FileSystem.readDirectory(folder)) {
					if (file.endsWith('.hxs')) {
						scriptArray.push(new Hscript(folder + file));
					}
				}
			}
		}

		startingSong = true;
		startCountdown();

		Paths.clearUnusedMemory();
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
									strumline.forEachAlive((strum:FlxSprite) -> {
										FlxTween.tween(strum, {angle: 360}, Conductor.crochet / 1000 * 2, {ease: FlxEase.cubeInOut});
									});
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

		if (paused)
			return;

		callOnScripts('update', [elapsed]);

		if (!startingSong && updateTime)
			timeTxt.text = "[" + msToTimestamp(FlxG.sound.music.time) + "/" + msToTimestamp(FlxG.sound.music.length) + "]";

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

		judgementCounter.text = 'Perfects: ${perfects}\nNices: ${nices}\nOkays: ${okays}\nNos: ${nos}';
		scoreTxt.text = (SaveData.settings.botPlay) ? Localization.get("botplayTxt",
			SaveData.settings.lang) : Localization.get("scoreTxt", SaveData.settings.lang)
			+ score
			+ ' // '
			+ Localization.get("missTxt", SaveData.settings.lang)
			+ misses;

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
				isPerfect = false;
				combo = 0;
				score -= 10;
				misses++;
				notes.remove(note);
				note.kill();
				note.destroy();
			}
		}

		if (Input.justPressed('exit') && canPause && startedCountdown)
			pause();

		if (Input.justPressed('seven'))
			openChartEditor();

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

		if (camZooming && FlxG.sound.music.playing)
			if (curBeat % (song.timeSignature[0] / 2) == 0)
				FlxTween.tween(FlxG.camera, {zoom: 1.03}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

		lastBeatHit = curBeat;
		callOnScripts('beatHit', [curBeat]);
	}

	override function openSubState(SubState:FlxSubState) {
		paused = true;
		FlxG.sound.music.pause();
		super.openSubState(SubState);
		Paths.clearUnusedMemory();
	}

	override function closeSubState() {
		paused = false;
		callOnScripts('resume', []);
		FlxG.sound.music.resume();
		super.closeSubState();
		Paths.clearUnusedMemory();
	}

	function pause() {
		var ret:Dynamic = callOnScripts('pause', []);
		if (ret != Hscript.Function_Stop) {
			openSubState(new PauseSubState());
			persistentUpdate = false;
			persistentDraw = true;
		}
	}

	function openChartEditor() {
		persistentUpdate = false;
		ExtendableState.switchState(new ChartingState());
		ChartingState.instance.song = song;
		chartingMode = true;
	}

	public var curRating:String = "perfect";

	function inputFunction() {
		var justPressed:Array<Bool> = [
			Input.justPressed('left'),
			Input.justPressed('down'),
			Input.justPressed('up'),
			Input.justPressed('right')
		];
		var pressed:Array<Bool> = [
			Input.pressed('left'),
			Input.pressed('down'),
			Input.pressed('up'),
			Input.pressed('right')
		];
		var released:Array<Bool> = [
			Input.justReleased('left'),
			Input.justReleased('down'),
			Input.justReleased('up'),
			Input.justReleased('right')
		];

		for (i in 0...justPressed.length) {
			if (justPressed[i]) {
				strumline.members[i].press();
				if (SaveData.settings.antiMash) {
					FlxG.sound.play(Paths.sound('miss${FlxG.random.int(1, 4)}'), 0.65);
					isPerfect = false;
					score -= 10;
					combo = 0;
					misses++;
				}
			}
		}

		for (i in 0...released.length)
			if (released[i])
				strumline.members[i].animation.play("receptor");

		var possibleNotes:Array<Note> = [];

		for (note in notes) {
			note.calculateCanBeHit();
			if (!SaveData.settings.botPlay) {
				if (note.canBeHit && !note.tooLate)
					possibleNotes.push(note);
			} else {
				if (note.strum <= Conductor.songPosition)
					possibleNotes.push(note);
			}
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		var doNotHit:Array<Bool> = [false, false, false, false];
		var noteDataTimes:Array<Float> = [-1, -1, -1, -1];

		if (possibleNotes.length > 0) {
			for (i in 0...possibleNotes.length) {
				var note = possibleNotes[i];

				if ((justPressed[getNoteIndex(note.dir)] && !doNotHit[getNoteIndex(note.dir)] && !SaveData.settings.botPlay)
					|| SaveData.settings.botPlay) {
					if (SaveData.settings.hitSoundVolume > 0)
						FlxG.sound.play(Paths.sound('hitsound'), SaveData.settings.hitSoundVolume / 100);

					var ratingScores:Array<Int> = [350, 200, 100, 50];

					var noteMs = (SaveData.settings.botPlay) ? 0 : (Conductor.songPosition - note.strum) / songMultiplier;
					var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);

					curRating = (isPerfect) ? "perfect-golden" : "perfect";

					if (Math.abs(noteMs) > 22.5)
						curRating = (isPerfect) ? 'perfect-golden' : 'perfect';

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
						case "perfect" | "perfect-golden":
							score += ratingScores[0];
							perfects++;
						case "nice":
							score += ratingScores[1];
							isPerfect = false;
							nices++;
						case "okay":
							score += ratingScores[2];
							isPerfect = false;
							okays++;
						case "no":
							score += ratingScores[3];
							isPerfect = false;
							nos++;
					}

					if (curRating == 'perfect' || curRating == 'perfect-golden') {
						var splash:NoteSplash = noteSplashes.recycle(NoteSplash);
						splash.setupSplash(note.x, note.y, getNoteIndex(note.dir));
						noteSplashes.add(splash);
					}

					ratingDisplay.showCurrentRating(curRating);
					ratingDisplay.screenCenter(X);

					combo++;

					var comboSplit:Array<String> = Std.string(combo).split('');
					var seperatedScore:Array<Int> = [];
					for (i in 0...comboSplit.length)
						seperatedScore.push(Std.parseInt(comboSplit[i]));

					var daLoop:Int = 0;

					for (i in seperatedScore) {
						var numScore:FlxSprite = new FlxSprite(0, 0);
						numScore.loadGraphic(Paths.image('gameplay/num' + Std.int(i) + ((isPerfect) ? '-golden' : '')));
						numScore.scale.set(0.5, 0.5);
						numScore.screenCenter();
						numScore.x = (FlxG.width * 0.65) + (60 * daLoop) - 160;
						numScore.y = (SaveData.settings.downScroll) ? ratingDisplay.y - 140 : ratingDisplay.y + 120;
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

	function checkForAchievement():Bool {
		return false; // placeholder for now
	}

	function endSong() {
		var ret:Dynamic = callOnScripts('endSong', []);
		if (ret != Hscript.Function_Stop) {
			timeTxt.visible = timeBar.visible = false;
			if (chartingMode) {
				openChartEditor();
				return;
			}
			ExtendableState.switchState(new SongSelectState());
			FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
			if (!SaveData.settings.botPlay)
				HighScore.saveScore(song.song, score);
			canPause = false;
		}
	}

	function generateSong() {
		Conductor.bpm = song.bpm;
		Conductor.recalculateStuff(songMultiplier);
		Conductor.safeZoneOffset *= songMultiplier;
		Conductor.songPosition = 0;

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

	function msToTimestamp(ms:Float) {
		var seconds = Math.round(ms) / 1000;
		var minutesLeft = Std.string(seconds / 60).split(".")[0];
		var secondsLeft = Std.string(seconds % 60).split(".")[0];
		return '${minutesLeft}:${(secondsLeft.length == 1 ? "0" : "") + secondsLeft}';
	}

	override function destroy() {
		scriptArray = [];
		callOnScripts('destroy', []);

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