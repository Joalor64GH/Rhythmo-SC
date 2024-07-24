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
		add(grid);

        logo = new FlxSprite(FlxG.width / 2, 0).loadGraphic(Paths.image('title/logo'));
        add(logo);

        playBtn = new Button(FlxG.width / 2, logo.y + 120, 'title/play', () -> {
            FlxG.switchState(PlayState.new);
        });
        add(playBtn);

        optionsBtn = new Button(FlxG.width / 2, playBtn.y + 120, 'title/options', () -> {
            trace('options menu unfinished sorry');
        });
        add(optionsBtn);
        
        exitBtn = new Button(FlxG.width / 2, optionsBtn.y + 120, 'title/exit', () -> {
            #if sys
            Sys.exit(0);
            #else
            System.exit(0);
            #end
        });
        add(exitBtn);

        var versii:FlxText = new FlxText(5, FlxG.height - 24, 0, 'v${Lib.application.meta.get('version')}' , 12);
        versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(versii);
    }

    override function update(elapsed:Float) {
		super.update(elapsed);
	}
}