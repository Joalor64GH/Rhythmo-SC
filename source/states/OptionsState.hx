package states;

class OptionState extends FlxState {
    final options:Array<String> = [
        "FPS Counter", 
        "Fullscreen", 
        "Antialiasing", 
        "Framerate", 
        "Controls", 
        "Language"
    ];

    var curSelected:Int = 0;
    var camObject:FlxObject;

    var notSelectedAlpha:Float = 0.55;
    
    override function create() {
        super.create();

        camObject = new FlxObject(80, 0, 0, 0);
		camObject.screenCenter(X);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('options/options_bg'));
        add(bg);

		var grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x2C00FF95, 0x0));
		grid.scrollFactor.set();
		grid.velocity.set(25, 25);
		add(grid);

        for (i in 0...options.length)
		{
			var text = new FlxText(80, 40 + (60 * i), 0, options[i], 20);
			text.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.alpha = notSelectedAlpha;
			add(text);
		}

        changeItem();

		FlxG.camera.follow(camObject, LOCKON, 0.25);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Input.is("up") || Input.is("down"))
            changeItem(Input.is("up") ? -1 : 1);

        if (Input.is("exit"))
            FlxG.switchState(MenuState.new);
    }

    function changeItem(number:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + number, 0, options - 1);
		camObject.y = usersAssets[curSelected].text.y;
        FlxG.sound.play(Paths.sound('scroll'));
	}
}