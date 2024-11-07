package states;

import backend.Song;

class PlayState extends ExtendableState {
	public static var instance:PlayState = null;
	public static var song:SongData = null;
	public static var songMultiplier:Float = 1;
	public static var chartingMode:Bool = false;
	public static var gotAchievement:Bool = false;

	public var konami:Int = 0;
	public var didKonami:Bool = false;

	public var speed:Float = 1;

	public var ratingDisplay:Rating;
	public var accuracy:Float = 0;
	public var score:Int = 0;
	public var combo:Int = 0;
	public var misses:Int = 0;
	public var hits:Int = 0;
	public var rank:String = "";
	public var scoreTxt:FlxText;

	public var precisions:Array<FlxText> = [];

	public var timeBar:Bar;
	public var updateTime:Bool = true;

	private var timeTxt:FlxText;

	public var judgementCounter:FlxText;
	public var perfects:Int = 0;
	public var nices:Int = 0;
	public var okays:Int = 0;
	public var nos:Int = 0;

	public var scriptArray:Array<Hscript> = [];

	public var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];
	public var noteSplashes:FlxTypedGroup<NoteSplash>;
	public var strumline:FlxTypedGroup<Note>;
	public var notes:FlxTypedGroup<Note>;
	public var spawnNotes:Array<Note> = [];

	public var camZooming:Bool = true;
	public var paused:Bool = false;
	public var startingSong:Bool = false;
	public var canPause:Bool = true;
	public var startedCountdown:Bool = false;

	public var countdown3:FlxSprite;
	public var countdown2:FlxSprite;
	public var countdown1:FlxSprite;
	public var go:FlxSprite;

	public var coolBG:FlxSprite;

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

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('gameplay/bg'));
		add(bg);

		coolBG = new FlxSprite().makeGraphic(820, FlxG.height, FlxColor.BLACK);
		coolBG.alpha = SaveData.settings.laneUnderlay / 100;
		coolBG.screenCenter(X);
		if (SaveData.settings.laneUnderlay != 0)
			add(coolBG);

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

		// load from "scripts" folder
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
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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

		countdown3 = new GameSprite().loadGraphic(Paths.image('gameplay/three'));
		countdown3.screenCenter();
		countdown3.visible = false;
		add(countdown3);

		countdown2 = new GameSprite().loadGraphic(Paths.image('gameplay/two'));
		countdown2.screenCenter();
		countdown2.visible = false;
		add(countdown2);

		countdown1 = new GameSprite().loadGraphic(Paths.image('gameplay/one'));
		countdown1.screenCenter();
		countdown1.visible = false;
		add(countdown1);

		go = new GameSprite().loadGraphic(Paths.image('gameplay/go'));
		go.screenCenter();
		go.visible = false;
		add(go);

		generateSong();

		// load from song folder
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

		for (script in scriptArray) {
			script.setVariable('addScript', function(path:String) {
				scriptArray.push(new Hscript('$path.hxs'));
			});
		}

		startingSong = true;
		startCountdown();

		// precache because cool
		for (key in ['miss1', 'miss2', 'miss3', 'miss4'])
			Paths.sound(key);

		Paths.music('Basically_Professionally_Musically');

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
			FlxG.sound.play(Paths.sound('cDown3'));
			FlxTween.tween(countdown3, {alpha: 0}, Conductor.crochet / 1000, {
				onComplete: (twn:FlxTween) -> {
					remove(countdown3);
					countdown3.destroy();
					countdown2.visible = true;
					FlxG.sound.play(Paths.sound('cDown2'));
					FlxTween.tween(countdown2, {alpha: 0}, Conductor.crochet / 1000, {
						onComplete: (twn:FlxTween) -> {
							remove(countdown2);
							countdown2.destroy();
							countdown1.visible = true;
							FlxG.sound.play(Paths.sound('cDown1'));
							FlxTween.tween(countdown1, {alpha: 0}, Conductor.crochet / 1000, {
								onComplete: (twn:FlxTween) -> {
									remove(countdown1);
									countdown1.destroy();
									go.visible = true;
									FlxG.sound.play(Paths.sound('cDownGo'));
									strumline.forEachAlive((strum:FlxSprite) -> {
										FlxTween.tween(strum, {angle: 360}, Conductor.crochet / 1000 * 2, {ease: FlxEase.cubeInOut});
									});
									FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
										onComplete: (twn:FlxTween) -> {
											remove(go);
											go.destroy();
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
		callOnScripts('update', [elapsed]);

		super.update(elapsed);

		if (paused)
			return;

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

		accuracy = (!SaveData.settings.botPlay) ? Utilities.boundTo(Math.floor((score * 100) / ((hits + misses) * 3.5)) * 0.01, 0, 100) : 0;
		judgementCounter.text = 'Perfects: ${perfects}\nNices: ${nices}\nOkays: ${okays}\nNos: ${nos}';
		scoreTxt.text = (SaveData.settings.botPlay) ? Localization.get("botplayTxt",
			SaveData.settings.lang) : Localization.get("scoreTxt", SaveData.settings.lang)
			+ score
			+ ' // '
			+ Localization.get("missTxt", SaveData.settings.lang)
			+ misses
			+ ' // Accuracy: $accuracy%'
			+ ' (${generateRank()})';

		if (spawnNotes.length > 0) {
			while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * songMultiplier)) {
				var dunceNote:Note = spawnNotes[0];
				notes.add(dunceNote);

				var index:Int = spawnNotes.indexOf(dunceNote);
				spawnNotes.splice(index, 1);
			}
		}

		for (note in notes) {
			var strum = strumline.members[Utilities.getNoteIndex(note.dir)];

			if (SaveData.settings.downScroll)
				note.y = strum.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			else
				note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

			if (Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null) {
				noteMiss(note.dir);
				destroyNote(note);
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
		if (!paused) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.pause();

			paused = true;
		}
		super.openSubState(SubState);

		Paths.clearUnusedMemory();
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.resume();

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
				if (!tmr.finished)
					tmr.active = true;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween) {
				if (!twn.finished)
					twn.active = true;
			});

			paused = false;
			callOnScripts('resume', []);
		}
		super.closeSubState();

		Paths.clearUnusedMemory();
	}

	function pause() {
		var ret:Dynamic = callOnScripts('pause', []);
		if (ret != Hscript.Function_Stop) {
			persistentUpdate = false;
			persistentDraw = true;

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
				if (!tmr.finished)
					tmr.active = false;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween) {
				if (!twn.finished)
					twn.active = false;
			});

			openSubState(new PauseSubState());
		}
	}

	function openChartEditor() {
		persistentUpdate = false;
		paused = true;
		ExtendableState.switchState(new ChartingState());
		ChartingState.song = song;
		chartingMode = true;
	}

	public var curRating:String = "perfect";

	var justPressed:Array<Bool> = [];
	var pressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	function inputFunction() {
		justPressed = [];
		pressed = [];
		released = [];

		for (i in 0...4) {
			if (!SaveData.settings.botPlay) {
				var key = noteDirs[i];
				justPressed.push(Input.justPressed(key));
				pressed.push(Input.pressed(key));
				released.push(Input.justReleased(key));
			} else { // prevent player input when botplay is on
				justPressed.push(false);
				pressed.push(false);
				released.push(false);
			}
		}

		if (Input.justPressed('left')) {
			if (konami == 4 || konami == 6) {
				konami += 1;
			} else {
				konami = 0;
			}
		}
		if (Input.justPressed('down')) {
			if (konami == 2 || konami == 3) {
				konami += 1;
			} else {
				konami = 0;
			}
		}
		if (Input.justPressed('up')) {
			if (konami == 0 || konami == 1) {
				konami += 1;
			} else {
				konami = 0;
			}
		}
		if (Input.justPressed('right')) {
			if (konami == 5 || konami == 7) {
				konami += 1;
				if (konami > 7)
					FlxG.sound.play(Paths.sound('unlock'));
			} else {
				konami = 0;
			}
		}

		if (konami == 8)
			didKonami = true;

		for (i in 0...justPressed.length) {
			if (justPressed[i]) {
				if (!SaveData.settings.botPlay)
					strumline.members[i].press();
				if (SaveData.settings.antiMash) {
					FlxG.sound.play(Paths.sound('miss${FlxG.random.int(1, 4)}'), 0.65);
					noteMiss(noteDirs[i]);
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

				if ((justPressed[Utilities.getNoteIndex(note.dir)]
					&& !doNotHit[Utilities.getNoteIndex(note.dir)]
					&& !SaveData.settings.botPlay)
					|| SaveData.settings.botPlay) {
					if (SaveData.settings.hitSoundVolume > 0)
						FlxG.sound.play(Paths.sound('hitsound' + SaveData.settings.hitSoundType), SaveData.settings.hitSoundVolume / 100);

					var noteMs = (SaveData.settings.botPlay) ? 0 : (Conductor.songPosition - note.strum) / songMultiplier;
					var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);

					curRating = (isPerfect) ? "perfect-golden" : "perfect";

					if (Math.abs(noteMs) > 22.5)
						curRating = (isPerfect) ? 'perfect-golden' : 'perfect';
					else if (Math.abs(noteMs) > 45)
						curRating = 'nice';
					else if (Math.abs(noteMs) > 90)
						curRating = 'okay';
					else if (Math.abs(noteMs) > 135)
						curRating = 'no';

					noteDataTimes[Utilities.getNoteIndex(note.dir)] = note.strum;
					doNotHit[Utilities.getNoteIndex(note.dir)] = true;

					if (!SaveData.settings.botPlay)
						strumline.members[Utilities.getNoteIndex(note.dir)].press();

					noteHit(note, curRating);
				}
			}

			if (possibleNotes.length > 0) {
				for (i in 0...possibleNotes.length) {
					var note = possibleNotes[i];

					if (note.strum == noteDataTimes[Utilities.getNoteIndex(note.dir)] && doNotHit[Utilities.getNoteIndex(note.dir)]) {
						note.active = false;
						destroyNote(note);
					}
				}
			}
		}
	}

	function destroyNote(note:Note) {
		notes.remove(note, true);
		note.kill();
		note.destroy();
	}

	function noteHit(note:Note, rating:String) {
		var ratingScores:Array<Int> = [350, 200, 100, 50];
		var scoreToAdd:Int = 0;

		switch (rating) {
			case "perfect" | "perfect-golden":
				scoreToAdd = ratingScores[0];
				perfects++;
			case "nice":
				scoreToAdd = ratingScores[1];
				isPerfect = false;
				nices++;
			case "okay":
				scoreToAdd = ratingScores[2];
				isPerfect = false;
				okays++;
			case "no":
				scoreToAdd = ratingScores[3];
				isPerfect = false;
				nos++;
		}

		score += scoreToAdd;
		combo++;
		hits++;

		if (rating == 'perfect' || rating == 'perfect-golden') {
			var splash:NoteSplash = noteSplashes.recycle(NoteSplash);
			splash.setupSplash(note.x, note.y, Utilities.getNoteIndex(note.dir));
			noteSplashes.add(splash);
		}

		ratingDisplay.showCurrentRating(rating);
		ratingDisplay.screenCenter(X);

		var comboSplit:Array<String> = Std.string(combo).split('');
		var seperatedScore:Array<Int> = [];
		for (i in 0...comboSplit.length)
			seperatedScore.push(Std.parseInt(comboSplit[i]));

		var daLoop:Int = 0;

		for (i in precisions)
			remove(i);
		var precision:FlxText = new FlxText(0, ((SaveData.settings.downScroll) ? -250 : 250), FlxG.width,
			Math.round(Conductor.songPosition - note.strum) + ' ms');
		precision.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		precision.screenCenter(X);
		FlxTween.tween(precision, {y: (SaveData.settings.downScroll ? -260 : 260)}, 0.01, {ease: FlxEase.bounceOut});
		precisions.push(precision);

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
			if (SaveData.settings.displayMS)
				add(precision);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: (twn:FlxTween) -> {
					numScore.destroy();
				},
				startDelay: 1
			});

			daLoop++;
		}

		if (SaveData.settings.displayMS) {
			FlxTween.tween(precision, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});
		}

		callOnScripts('noteHit', [note, rating]);

		note.active = false;
		destroyNote(note);
	}

	function noteMiss(direction:String) {
		isPerfect = false;
		combo = 0;
		score -= 10;
		misses++;
		callOnScripts('noteMiss', [direction]);
	}

	function generateRank():String {
		var rankConditions:Array<Bool> = [
			accuracy >= 100, // P
			accuracy >= 95, // S
			accuracy >= 90, // A
			accuracy >= 80, // B
			accuracy >= 70, // C
			accuracy >= 60, // D
			accuracy <= 60 // F
		];

		var rankArray:Array<String> = ["P", "S", "A", "B", "C", "D", "F"];

		for (i in 0...rankConditions.length) {
			if (rankConditions[i]) {
				rank = rankArray[i];
				break;
			}
		}

		if (accuracy <= 0 || SaveData.settings.botPlay)
			rank = "?";

		return rank;
	}

	function endSong() {
		var ret:Dynamic = callOnScripts('endSong', []);
		if (ret != Hscript.Function_Stop) {
			timeTxt.visible = timeBar.visible = false;
			canPause = false;

			if (chartingMode) {
				openChartEditor();
				return;
			}

			if (!gotAchievement) {
				var achievementName = checkForAchievement([
					'full_combo', 'single_digit_miss', 'multi_miss', 'perfect', 'super', 'amazing', 'be_better', 'can_improve', 'dont_give_up', 'failed',
					'konami'
				]);

				if (achievementName != null)
					return;
			}

			if (!SaveData.settings.botPlay)
				HighScore.saveScore(song.song, score);
			new FlxTimer().start(0.5, (tmr:FlxTimer) -> {
				persistentUpdate = true;
				openSubState(new ResultsSubState(rank, score, accuracy));
			});
		}
	}

	function checkForAchievement(achs:Array<String> = null):String {
		if (chartingMode || SaveData.settings.botPlay)
			return null;

		for (i in 0...achs.length) {
			var achievementName:String = achs[i];
			if (!Achievements.isUnlocked(achievementName) && !SaveData.settings.botPlay) {
				var unlock:Bool = false;

				switch (achievementName) {
					case 'full_combo':
						if (misses == 0)
							unlock = true;
					case 'single_digit_miss':
						if (misses > 0 && misses < 10)
							unlock = true;
					case 'multi_miss':
						if (misses > 10)
							unlock = true;
					case 'perfect':
						if (rank == "P")
							unlock = true;
					case 'super':
						if (rank == "S")
							unlock = true;
					case 'amazing':
						if (rank == "A")
							unlock = true;
					case 'be_better':
						if (rank == "B")
							unlock = true;
					case 'can_improve':
						if (rank == "C")
							unlock = true;
					case 'dont_give_up':
						if (rank == "D")
							unlock = true;
					case 'failed':
						if (rank == "F")
							unlock = true;
					case 'konami':
						if (didKonami)
							unlock = true;
				}

				if (unlock) {
					gotAchievement = true;
					Achievements.unlock(achievementName, {
						date: Date.now(),
						song: song.song
					}, () -> {
						trace('finished showing achievement');
						gotAchievement = false;
						endSong();
					});
					return achievementName;
				}
			}
		}

		return null;
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