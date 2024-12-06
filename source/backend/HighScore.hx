package backend;

class HighScore {
	public static var songScores:Map<String, Int> = new Map();

	public static function saveScore(song:String, score:Int = 0):Void {
		if (songScores.exists(song)) {
			if (songScores.get(song) < score)
				setScore(song, score);
		} else
			setScore(song, score);
	}

	static function setScore(song:String, score:Int):Void {
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function getScore(song:String):Int {
		if (!songScores.exists(song))
			setScore(song, 0);

		return songScores.get(song);
	}

	public static function resetSong(song:String):Void {
		setScore(song, 0);
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;
	}
}