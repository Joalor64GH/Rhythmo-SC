package game;

import game.Section.SectionData;

typedef SongData = {
	var song:String;
	var notes:Array<SectionData>;
	var bpm:Float;

	var timeSignature:Array<Int>;
}

class Song {
	public static function loadSongfromJson(song:String):Dynamic {
		#if sys
		return Json.parse(File.getContent(Paths.chart(song)));
		#else
		return Json.parse(Assets.getText(Paths.chart(song)));
		#end
	}
}