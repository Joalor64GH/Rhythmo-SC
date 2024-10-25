package states;

import backend.Conductor;
import backend.Song;
import objects.Note;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import flixel.addons.ui.FlxUIInputText;

class ChartingState extends ExtendableState {
	public static var instance:ChartingState = null;

	public var song:SongData;

	var gridBG:FlxSprite;
	var gridSize:Int = 40;
	var columns:Int = 4;
	var rows:Int = 16;

	var curSection:Int = 0;
	var dummyArrow:FlxSprite;

	var beatSnap:Int = 16;

	var renderedNotes:FlxTypedGroup<Note>;

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

	var saveButton:FlxButton;
	var saveAsButton:FlxButton;

	var clearSectionButton:FlxButton;
	var clearSongButton:FlxButton;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic> = [];
	var copySectionButton:FlxButton;
	var pasteSectionButton:FlxButton;

	var strumLine:FlxSprite;

	var undos = [];
	var redos = [];

	var _file:FileReference;

	override function create() {
		super.create();

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;

		loadSong(Paths.formatToSongPath(song.song));
		beatSnap = Conductor.stepsPerSection;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/bg'));
		bg.color = 0xFF444444;
		add(bg);

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

		saveButton = new FlxButton(FlxG.width - 110, 10, "Save Chart", () -> {
			try {
				var chart:String = Json.stringify(song);
				File.saveContent(Paths.chart(Paths.formatToSongPath(song.song)), chart);
				trace("chart saved!\nsaved path: " + Paths.chart(Paths.formatToSongPath(song.song)));
			} catch (e:Dynamic) {
				trace("Error while saving chart: " + e);
			}
		});
		add(saveButton);

		saveAsButton = new FlxButton(FlxG.width - 110, 40, "Save Chart As", () -> {
			var json = {
				"song": song
			};

			var data:String = Json.stringify(json);

			if ((data != null) && (data.length > 0)) {
				_file = new FileReference();
				_file.addEventListener(Event.COMPLETE, onSaveComplete);
				_file.addEventListener(Event.CANCEL, onSaveCancel);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				_file.save(data.trim(), Paths.formatToSongPath(song.song) + ".json");
			}
		});
		add(saveAsButton);

		copySectionButton = new FlxButton(FlxG.width - 110, 70, "Copy Section", () -> {
			notesCopied = [];
			sectionToCopy = curSection;
			for (i in 0...song.notes[curSection].sectionNotes.length)
				notesCopied.push(song.notes[curSection].sectionNotes[i]);
		});
		add(copySectionButton);

		pasteSectionButton = new FlxButton(FlxG.width - 110, 100, "Paste Section", () -> {
			if (notesCopied == null || notesCopied.length < 1)
				return;

			for (note in notesCopied) {
				var clonedNote = {
					noteStrum: note.noteStrum + Conductor.stepCrochet * (4 * 4 * (curSection - sectionToCopy)),
					noteData: note.noteData
				};
				song.notes[curSection].sectionNotes.push(clonedNote);
			}

			updateGrid();
		});
		add(pasteSectionButton);

		clearSectionButton = new FlxButton(FlxG.width - 110, 130, "Clear Section", () -> {
			song.notes[curSection].sectionNotes = [];
			updateGrid();
		});
		add(clearSectionButton);

		clearSongButton = new FlxButton(FlxG.width - 110, 160, "Clear Song", () -> {
			openSubState(new PromptSubState(Localization.get("youDecide", SaveData.settings.lang), () -> {
				for (daSection in 0...song.notes.length)
					song.notes[daSection].sectionNotes = [];
				updateGrid();
			}));
		});
		add(clearSongButton);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		var prototypeNotice:FlxText = new FlxText(5, FlxG.height - 24, 0, 'Charter v0.2-BETA // Functionality is subject to change.', 12);
		prototypeNotice.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		prototypeNotice.scrollFactor.set();
		add(prototypeNotice);

		// FlxG.camera.follow(strumLine);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * song.notes[curSection].stepsPerSection));

		if (curBeat % 4 == 0 && curStep > 16 * (curSection + 1)) {
			if (song.notes[curSection + 1] == null) {
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		if (Input.justPressed('left'))
			changeSection(curSection - 1);
		if (Input.justPressed('right'))
			changeSection(curSection + 1);

		if (Input.justPressed('accept')) {
			FlxG.mouse.visible = false;
			if (FlxG.sound.music.playing)
				FlxG.sound.music.stop();
			ExtendableState.switchState(new PlayState());
			PlayState.song = song;
		}

		if (Input.justPressed('space')) {
			if (FlxG.sound.music.playing)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.play();
		}

		if (Input.justPressed('z') && Input.pressed('control'))
			undo();

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (gridSize * Conductor.stepsPerSection)) {
			var snappedGridSize = (gridSize / (beatSnap / Conductor.stepsPerSection));

			dummyArrow.x = Math.floor(FlxG.mouse.x / gridSize) * gridSize;

			if (Input.pressed('shift'))
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

						if (Input.pressed('control'))
							selectNote(note);
						else {
							trace("trying to delete note");
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
			curSection = 0;
			updateGrid();
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
		for (sectionNote in song.notes[curSection].sectionNotes)
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData % 4 == Utilities.getNoteIndex(note.dir))
				song.notes[curSection].sectionNotes.remove(sectionNote);

		updateGrid();
	}

	function selectNote(note:Note):Void {
		var swagNum:Int = 0;

		for (sectionNote in song.notes[curSection].sectionNotes) {
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData % 4 == Utilities.getNoteIndex(note.dir)) {
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
			var direction:String = Utilities.getDirection(sectionNote.noteData % 4);
			var note:Note = new Note(0, 0, direction, "note");

			note.setGraphicSize(gridSize, gridSize);
			note.updateHitbox();

			note.x = gridBG.x + Math.floor((sectionNote.noteData % 4) * gridSize);
			note.y = Math.floor(getYfromStrum((sectionNote.noteStrum - sectionStartTime())));

			note.strum = sectionNote.noteStrum;
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

	function loadJson(song:String):Void {
		PlayState.song = Song.loadSongfromJson(Paths.formatToSongPath(song));
		ExtendableState.resetState();
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		trace("Successfully saved song.");
	}

	function onSaveCancel(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		trace("Problem saving song");
	}

	function undo() {
		undos.pop();
	}

	function redo() {}
}