package game;

typedef HighScoreData = {
    var songName:String;
    var score:Int;
};

class HighScore {
    public static var highScores:Array<HighScoreData> = [];

    public static function loadHighScores():Void {
        var fileName:String = Paths.json("highScores");
        if (FileSystem.exists(fileName)) {
            var fileContent:String = File.getContent(fileName);
            highScores = Json.parse(fileContent);
        }
    }

    public static function saveHighScores():Void {
        var fileName:String = Paths.json("highScores");
        var serializedData:String = Json.stringify(highScores);
        File.saveContent(fileName, serializedData);
    }

    public static function addHighScore(songName:String, score:Int):Void {
        highScores.push({songName: songName, score: score});
        saveHighScores();
    }

    public static function getHighScores():Array<HighScore> {
        return highScores;
    }
}