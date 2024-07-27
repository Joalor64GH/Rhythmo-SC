package states;

typedef BasicData = {
    var songs:Array<Song>;
}

typedef Song = {
    var name:String;
    var music:String;
}

class SongSelectState extends ExtendableState {
    var bg:FlxSprite;
    var cover:FlxSprite;

    var curSelected:Int = 0;
    var musicData:BasicData;

    var arrowL:FlxSprite;
    var arrowR:FlxSprite;

    override public function create() {
        super.create();

        musicData = Json.parse(Paths.getTextFromFile('data/songList.json'));

        var topPanel:FlxSprite = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 26, FlxColor.BLACK);
		topPanel.alpha = 0.6;
		add(topPanel);

        var bottomPanel:FlxSprite = new FlxSprite(0, -FlxG.height).makeGraphic(FlxG.width, 26, FlxColor.BLACK);
		bottomPanel.alpha = 0.6;
		add(bottomPanel);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}