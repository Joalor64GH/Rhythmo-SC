package game;

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