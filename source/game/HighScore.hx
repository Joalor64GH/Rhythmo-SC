package game;

class HighScore {
    public static var songScores:Map<String, Int> = new Map();

    public static function saveScore(song:String, score:Int = 0):Void {
        var formattedSong:String = formatSong(song);
        if (songScores.exists(formattedSong)) {
            if (songScores.get(formattedSong) < score) {
                setScore(formattedSong, score);
            }
        } else
            setScore(formattedSong, score);
    }

    static function setScore(song:String, score:Int):Void {
        songScores.set(song, score);
        saveScoresToFile();
    }

    public static function formatSong(song:String):String {
        return song.toLowerCase().replace(" ", "_");
    }

    public static function getScore(song:String):Int {
        var formattedSong:String = formatSong(song);
        if (!songScores.exists(formattedSong))
            setScore(formattedSong, 0);
        return songScores.get(formattedSong);
    }

    public static function load():Void {
        if (FileSystem.exists(Paths.json("highScores"))) {
            var loadedScores:Map<String, Int> = Json.parse(File.getContent(Paths.json("highScores")));
            songScores = loadedScores;
        }
    }

    public static function saveScoresToFile():Void {
        var serializedData:String = Json.stringify(songScores);
        File.saveContent(Paths.json("highScores"), serializedData);
    }
}