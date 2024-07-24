package states;

class MenuState extends FlxState {
    var playBtn:Button;
    var optionsBtn:Button;
    var exitBtn:Button;

    var logo:FlxSprite;

    override function create() {
        super.create();

        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/title_bg'));
        add(bg);

        var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 0.6}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

        var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/logo'));
        logo.screenCenter(X);
        logo.setGraphicSize(0.55, 0.55);
        add(logo);

        playBtn = new Button(0, logo.y + 150, 'title/play', () -> {
            FlxG.switchState(PlayState.new);
        });
        add(playBtn);

        optionsBtn = new Button(0, playBtn.y + 200, 'title/options', () -> {
            trace('options menu unfinished sorry');
        });
        add(optionsBtn);

        exitBtn = new Button(0, optionsBtn.y + 300, 'title/exit', () -> {
            Sys.exit(0);
        });
        add(exitBtn);
    }

    override function update(elapsed:Float) {
		super.update(elapsed);
	}
}