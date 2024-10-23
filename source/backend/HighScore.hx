package backend;

class HighScore {
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();

	public static function saveScore(song:String, score:Int = 0, ?rating:Float = -1):Void {
		if (songScores.exists(song)) {
			if (songScores.get(song) < score) {
				setScore(song, score);
				if (rating >= 0) setRating(song, rating);
			}
		} else {
			setScore(song, score);
			if (rating >= 0) setRating(song, rating);
		}
	}

	static function setScore(song:String, score:Int):Void {
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void {
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	public static function getScore(song:String):Int {
		if (!songScores.exists(song))
			setScore(song, 0);

		return songScores.get(song);
	}

	public static function getRating(song:String):Float {
		if (!songRating.exists(song))
			setRating(song, 0);

		return songRating.get(song);
	}

	public static function resetSong(song:String):Void {
		setScore(song, 0);
		setRating(song, 0);
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;
		if (FlxG.save.data.songRating != null)
			songRating = FlxG.save.data.songRating;
	}
}