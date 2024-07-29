package game;

class HighScore { // yes i know this is fnf code, but WHATEVER
	public static var songScores:Map<String, Int> = new Map();

	public static function saveScore(song:String, score:Int = 0):Void {
		var daSong:String = formatSong(song);
		if (songScores.exists(song)) {
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		} else
			setScore(daSong, score);
	}

	static function setScore(song:String, score:Int):Void {
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String):String {
		return song;
	}

	public static function getScore(song:String):Int {
		if (!songScores.exists(formatSong(song)))
			setScore(formatSong(song), 0);

		return songScores.get(formatSong(song));
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;
	}
}