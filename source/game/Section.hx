package game;

typedef SwagSection = {
	var sectionNotes:Array<SwagNote>;
	var bpm:Float;
	var changeBPM:Bool;

	var timeScale:Array<Int>;
	var changeTimeScale:Bool;
}

typedef SwagNote = {
	var noteStrum:Float;
	var noteData:Int;
}