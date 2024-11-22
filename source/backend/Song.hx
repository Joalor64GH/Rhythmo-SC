package backend;

typedef SongData = {
	var song:String;
	var notes:Array<SectionData>;
	var bpm:Float;

	var timeSignature:Array<Int>;
}

typedef SectionData = {
	var sectionNotes:Array<NoteData>;
	var bpm:Float;
	var changeBPM:Bool;

	var timeScale:Array<Int>;
	var changeTimeScale:Bool;
	var stepsPerSection:Int;
}

typedef NoteData = {
	var noteStrum:Float;
	var noteData:Int;
}

class Song {
	public static function loadSongfromJson(song:String):Dynamic
		return Json.parse(Paths.getText(Paths.chart(song)));
}