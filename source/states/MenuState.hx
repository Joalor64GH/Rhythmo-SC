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

        logo = new FlxSprite(0, 0).loadGraphic(Paths.image('title/logo'));
        logo.x = (FlxG.width - logo.width * logo.scale.x) / 2;
        logo.y = 0;
        logo.scale.set(0.4, 0.4);
        add(logo);

        playBtn = new Button(0, logo.y + 120, 'title/play', () -> {
            FlxG.switchState(PlayState.new);
        });
        playBtn.screenCenter(X);
        add(playBtn);

        optionsBtn = new Button(0, playBtn.y + 120, 'title/options', () -> {
            trace('options menu unfinished sorry');
        });
        optionsBtn.screenCenter(X);
        add(optionsBtn);
        
        exitBtn = new Button(0, optionsBtn.y + 120, 'title/exit', () -> {
            Sys.exit(0);
        });
        exitBtn.screenCenter(X);
        add(exitBtn);

        var versii:FlxText = new FlxText(5, FlxG.height - 24, 0, 'v${Lib.application.meta.get('version')}' , 12);
        versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(versii);
    }

    override function update(elapsed:Float) {
		super.update(elapsed);
	}
}