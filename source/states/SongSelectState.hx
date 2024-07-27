package states;

typedef BasicData = {
    var songs:Array<Song>;
}

typedef Song = {
    var name:String;
    var music:String;
    var diff:String;
}

class SongSelectState extends ExtendableState {
    var bg:FlxSprite;
    var cover:FlxSprite;

    var curSelected:Int = 0;
    var musicData:BasicData;

    var arrowL:FlxSprite;
    var arrowR:FlxSprite;

    var scoreTxt:FlxText;
    var diffTxt:FlxText;

    override public function create() {
        super.create();

        musicData = Json.parse(Paths.getTextFromFile('data/songList.json'));

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('selector/selector_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

        var topPanel:FlxSprite = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 26, FlxColor.BLACK);
		topPanel.alpha = 0.6;
		add(topPanel);

        var bottomPanel:FlxSprite = new FlxSprite(0, -FlxG.height).makeGraphic(FlxG.width, 26, FlxColor.BLACK);
		bottomPanel.alpha = 0.6;
		add(bottomPanel);

        arrowL = new FlxSprite(-FlxG.width, 0).loadGraphic(Paths.image('selector/arrow'));
        arrowL.screenCenter(Y);
        arrowL.flipX = true;
        add(arrowL);

        arrowR = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('selector/arrow'));
        arrowR.screenCenter(Y);
        add(arrowR);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}