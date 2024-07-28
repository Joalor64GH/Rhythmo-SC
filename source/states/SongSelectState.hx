package states;

typedef BasicData = {
    var songs:Array<Song>;
}

typedef Song = {
    var name:String;
    var diff:String;
}

class Cover extends FlxSprite
{
    public var lerpSpeed:Float = 6;
    public var posX:Float = 0;

    function boundTo(value:Float, min:Float, max:Float):Float {
        return Math.max(min, Math.min(max, value));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 760, boundTo(elapsed * lerpSpeed, 0, 1));
    }
}

class SongSelectState extends ExtendableState {
    var bg:FlxSprite;
    var coverGrp:FlxTypedGroup<Cover>;

    var currentIndex:Int = 0;
    var songListData:BasicData;

    var panelTxt:FlxText;
    var panel:FlxSprite;

    override function create() {
        super.create();

        songListData = Json.parse(Paths.getTextFromFile('data/songList.json'));

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('selector/selector_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

        coverGrp = new FlxTypedGroup<Cover>();
        add(coverGrp);

        for (i in 0...songListData.songs.length)
        {
            var newItem:Cover = new Cover();
            newItem.loadGraphic(Paths.image('selector/thumbnails/' + songListData.songs[i].name.toLowerCase()));
            newItem.scale.set(0.6, 0.6);
            newItem.ID = i;
            coverGrp.add(newItem);
        }

        panel:FlxSprite = new FlxSprite(0, -FlxG.height).makeGraphic(FlxG.width, 26, FlxColor.BLACK);
		panel.alpha = 0.6;
		add(panel);

        panelTxt:FlxText = new FlxText(panel.x, panel.y + 4, FlxG.width, "Score: 0 // Difficulty: ☆☆", 32);
		panelTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		panelTxt.screenCenter(X);
		add(panelTxt);

        var arrowL:FlxSprite = new FlxSprite(-FlxG.width, 0).loadGraphic(Paths.image('selector/arrow'));
        arrowL.screenCenter(Y);
        arrowL.flipX = true;
        add(arrowL);

        var arrowR:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('selector/arrow'));
        arrowR.screenCenter(Y);
        add(arrowR);

        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Input.is("exit")) {
            ExtendableState.switchState(new MenuState());
            FlxG.sound.play(Paths.sound('cancel'));
        }

        if (Input.is("left") || Input.is("right")) {
            FlxG.sound.play(Paths.sound('scroll'));
            changeSelection(Input.is("left") ? -1 : 1);
        }
    }

    private function changeSelection(i:Int = 0) {
        currentIndex = FlxMath.wrap(currentIndex + i, 0, songListData.songs.length - 1);
        for (num => item in coverGrp) {
            item.posX = num++ - currentIndex;
            item.alpha = (item.ID == currentIndex) ? 1 : 0.6;
        }
    }
}