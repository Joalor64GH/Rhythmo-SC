package states;

typedef BasicData = {
    var songs:Array<SongArray>;
}

typedef SongArray = {
    var name:String;
    var diff:String;
}

class Cover extends FlxSprite {
    public var lerpSpeed:Float = 6;
    public var posX:Float = 0;

    function boundTo(value:Float, min:Float, max:Float):Float {
        return Math.max(min, Math.min(max, value));
    }

    override function update(elapsed:Float) {
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
    var bottomPanel:FlxSprite;

    var titleTxt:FlxText;

    var lerpScore:Int = 0;
    var intendedScore:Int = 0;

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

        for (i in 0...songListData.songs.length) {
            var newItem:Cover = new Cover();
            try {
                newItem.loadGraphic(Paths.image('selector/covers/' + songListData.songs[i].name.toLowerCase()));
            } catch(e) {
                trace("oops! cover returned null!");
                newItem.loadGraphic(Paths.image('selector/covers/placeholder'));
            }
            newItem.scale.set(0.6, 0.6);
            newItem.ID = i;
            coverGrp.add(newItem);
        }

        bottomPanel = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.6;
		add(bottomPanel);

        panelTxt = new FlxText(bottomPanel.x, bottomPanel.y + 4, FlxG.width, "", 32);
		panelTxt.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        panelTxt.scrollFactor.set();
		panelTxt.screenCenter(X);
		add(panelTxt);

        titleTxt = new FlxText(0, 0, FlxG.width, "", 32);
		titleTxt.setFormat(Paths.font('vcr.ttf'), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        titleTxt.scrollFactor.set();
		titleTxt.screenCenter(X);
		add(titleTxt);

        var arrowL:FlxSprite = new FlxSprite(-FlxG.width + 280, FlxG.height / 2).loadGraphic(Paths.image('selector/arrow'));
        arrowL.scrollFactor.set();
        arrowL.scale.set(0.5, 0.5);
        arrowL.flipX = true;
        add(arrowL);

        var arrowR:FlxSprite = new FlxSprite(FlxG.width - 280, FlxG.height / 2).loadGraphic(Paths.image('selector/arrow'));
        arrowR.scrollFactor.set();
        arrowR.scale.set(0.5, 0.5);
        add(arrowR);

        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
        panelTxt.text = "Score: " + lerpScore + " // Difficulty: " + songListData.songs[currentIndex].diff;

        if (Input.is("exit")) {
            ExtendableState.switchState(new MenuState());
            FlxG.sound.play(Paths.sound('cancel'));
        }

        if (Input.is("left") || Input.is("right")) {
            FlxG.sound.play(Paths.sound('scroll'));
            changeSelection(Input.is("left") ? -1 : 1);
        }

        if (Input.is("accept")) {
            PlayState.song = Song.loadSongfromJson(Paths.formatToSongPath(songListData.songs[currentIndex].name));
            ExtendableState.switchState(new PlayState());
            FlxG.sound.music.stop();
        }
    }

    private function changeSelection(i:Int = 0) {
        currentIndex = FlxMath.wrap(currentIndex + i, 0, songListData.songs.length - 1);
        for (num => item in coverGrp) {
            item.posX = num++ - currentIndex;
            item.alpha = (item.ID == currentIndex) ? 1 : 0.6;
        }

        titleTxt.text = songListData.songs[currentIndex].name;
        intendedScore = HighScore.getScore(songListData.songs[currentIndex].name);
    }
}