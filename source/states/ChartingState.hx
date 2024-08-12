package states;

import game.Conductor;
import game.Note;
import game.Section;
import game.Song;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUINumericStepper;

class ChartingState extends ExtendableState {
	public static var instance:ChartingState;

	var gridSize:Int = 40;
	var columns:Int = 4;
	var rows:Int = 16;

	var gridBG:FlxSprite;

	var curSection:Int = 0;
	var dummyArrow:FlxSprite;

	var beatSnap:Int = 16;

	var renderedNotes:FlxTypedGroup<Note>;

	public var song:SongData;

	override public function new() {
		super();

		instance = this;

		song = {
			song: "Test",
			notes: [],
			bpm: 100,
			timeSignature: [4, 4]
		};
	}

	var curSelectedNote:NoteData;

	var songInfoText:FlxText;
	var bpmStepper:FlxUINumericStepper;
	var saveButton:FlxButton;

	var strumLine:FlxSprite;

	override function create() {
		super.create();

		loadSong(Paths.formatToSongPath(song.song));

		beatSnap = Conductor.stepsPerSection;

		gridBG = FlxGridOverlay.create(gridSize, gridSize, gridSize * columns, gridSize * rows, true, 0xFF404040, 0xFF525252);
		gridBG.screenCenter();
		add(gridBG);

		dummyArrow = new GameSprite().makeGraphic(gridSize, gridSize);
		add(dummyArrow);

		renderedNotes = new FlxTypedGroup<Note>();
		add(renderedNotes);

		addSection();
		updateGrid();

		songInfoText = new FlxText(10, 10, 0, 18);
		add(songInfoText);

		saveButton = new FlxButton(FlxG.width - 110, 10, "Save Chart", saveChart);
		add(saveButton);

		bpmStepper = new FlxUINumericStepper(saveButton.x, 55, 1, 1, 1, 9999, 3);
		bpmStepper.value = song.bpm;
		add(bpmStepper);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		// FlxG.camera.follow(strumLine);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * song.notes[curSection].stepsPerSection));

		if (Input.is("exit"))
			ExtendableState.switchState(new MenuState());

		if (Input.is("left"))
			changeSection(curSection - 1);

		if (Input.is("right"))
			changeSection(curSection + 1);

		if (Input.is("accept")) {
			ExtendableState.switchState(new PlayState());
			PlayState.song = song;
		}

		if (Input.is("space")) {
			if (FlxG.sound.music.playing)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.play();
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (gridSize * Conductor.stepsPerSection)) {
			var snappedGridSize = (gridSize / (beatSnap / Conductor.stepsPerSection));

			dummyArrow.x = Math.floor(FlxG.mouse.x / gridSize) * gridSize;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / snappedGridSize) * snappedGridSize;
		}

		if (FlxG.mouse.justPressed) {
			var coolNess = true;

			if (FlxG.mouse.overlaps(renderedNotes)) {
				renderedNotes.forEach(function(note:Note) {
					if (FlxG.mouse.overlaps(note)
						&& (Math.floor((gridBG.x + FlxG.mouse.x / gridSize) - 2)) == note.rawNoteData && coolNess) {
						coolNess = false;

						if (FlxG.keys.pressed.CONTROL) {
							selectNote(note);
						} else {
							deleteNote(note);
						}
					}
				});
			}

			if (coolNess) {
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (gridSize * Conductor.stepsPerSection)) {
					addNote();
				}
			}
		}

		Conductor.songPosition = FlxG.sound.music.time;

		songInfoText.text = ("Time: "
			+ Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nBPM: "
			+ song.bpm
			+ "\nCurStep: "
			+ curStep
			+ "\nCurBeat: "
			+ curBeat
			+ "\nNote Snap: "
			+ beatSnap
			+ (FlxG.keys.pressed.SHIFT ? "\n(DISABLED)" : "\n(CONTROL + ARROWS)")
			+ "\n");
	}

	function loadSong(daSong:String):Void {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.music = new FlxSound().loadEmbedded(Paths.song(daSong));
		FlxG.sound.music.pause();
		FlxG.sound.music.onComplete = function() {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function addNote() {
		if (song.notes[curSection] == null)
			addSection();

		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((gridBG.x + (FlxG.mouse.x / gridSize)) - 2);

		song.notes[curSection].sectionNotes.push({
			noteStrum: noteStrum,
			noteData: noteData
		});

		updateGrid();
	}

	function deleteNote(note:Note):Void {
		if (song.notes[curSection] == null)
			return;

		var notesToRemove:Array<NoteData> = [];

		for (sectionNote in song.notes[curSection].sectionNotes)
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData == getNoteIndex(note.dir))
				notesToRemove.push(sectionNote);

		for (sectionNote in notesToRemove)
			song.notes[curSection].sectionNotes.remove(sectionNote);

		renderedNotes.remove(note, true);
		note.kill();
		note.destroy();

		updateGrid();
	}

	function selectNote(note:Note):Void {
		var swagNum:Int = 0;

		for (sectionNote in song.notes[curSection].sectionNotes) {
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData == getNoteIndex(note.dir)) {
				curSelectedNote = sectionNote;
			}

			swagNum++;
		}

		updateGrid();
	}

	function updateGrid() {
		renderedNotes.forEach(function(note:Note) {
			note.kill();
			note.destroy();
		}, true);

		renderedNotes.clear();

		for (sectionNote in song.notes[curSection].sectionNotes) {
			var direction:String = getDirection(sectionNote.noteData % 4);
			var note:Note = new Note(0, 0, direction, "note");

			note.setGraphicSize(gridSize, gridSize);
			note.updateHitbox();

			note.x = gridBG.x + Math.floor((sectionNote.noteData % 4) * gridSize);
			note.y = Math.floor(getYfromStrum((sectionNote.noteStrum - sectionStartTime())));

			note.rawNoteData = sectionNote.noteData;

			renderedNotes.add(note);
		}
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, Conductor.stepsPerSection * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, Conductor.stepsPerSection * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function addSection(?coolLength:Int = 0):Void {
		var col:Int = Conductor.stepsPerSection;

		if (coolLength == 0)
			col = Std.int(Conductor.timeScale[0] * Conductor.timeScale[1]);

		var sec:SectionData = {
			sectionNotes: [],
			bpm: song.bpm,
			changeBPM: false,
			timeScale: Conductor.timeScale,
			changeTimeScale: false,
			stepsPerSection: 16
		};

		song.notes.push(sec);
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void {
		trace('changing section' + sec);

		if (song.notes[sec] != null) {
			curSection = sec;

			if (curSection < 0)
				curSection = 0;

			updateGrid();

			if (updateMusic) {
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				updateCurStep();
			}

			updateGrid();
		} else {
			addSection();

			curSection = sec;

			if (curSection < 0)
				curSection = 0;

			updateGrid();

			if (updateMusic) {
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				updateCurStep();
			}

			updateGrid();
		}
	}

	function resetSection(songBeginning:Bool = false):Void {
		updateGrid();

		FlxG.sound.music.pause();
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning) {
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		updateCurStep();

		updateGrid();
	}

	function sectionStartTime(?section:Int):Float {
		if (section == null)
			section = curSection;

		var daBPM:Float = song.bpm;
		var daPos:Float = 0;

		for (i in 0...section) {
			if (song.notes[i].changeBPM)
				daBPM = song.notes[i].bpm;

			daPos += Conductor.timeScale[0] * (1000 * (60 / daBPM));
		}

		return daPos;
	}

	function saveChart():Void {
		try {
			var chart:String = Json.stringify(song);
			File.saveContent(Paths.chart(Paths.formatToSongPath(song.song)), chart);
			trace("chart saved!");
		} catch (e:Dynamic) {
			trace("Error while saving chart: " + e);
		}
	}

	function getDirection(index:Int):String {
		return switch (index) {
			case 0: "left";
			case 1: "down";
			case 2: "up";
			case 3: "right";
			default: "unknown";
		}
	}

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
