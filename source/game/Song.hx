package game;

import game.Section.SectionData;

typedef SongData = {
	var song:String;
	var notes:Array<SectionData>;
	var bpm:Float;

	var timeSignature:Array<Int>;
}