package states;

class MenuState extends FlxState {
    var curSelected:Int = 0;
    var grpSelection:FlxTypedGroup<FlxSprite>;
    var selections:Array<String> = ['play', 'options', 'exit'];

    var logo:FlxSprite;

    override function create() {
        super.create();

        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/title_bg'));
        add(bg);

        var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

        logo = new FlxSprite(0, 0).loadGraphic(Paths.image('title/logo'));
        logo.scale.set(0.25, 0.25);
        logo.screenCenter(X);
        add(logo);

        grpSelection = new FlxTypedGroup<FlxSprite>();
        add(grpSelection);

        for (i in 0...selections.length) {
            var menuItem:FlxSprite = new FlxSprite(0, i * 200).loadGraphic(Paths.image('title/' + selections[i]));
            menuItem.scale.set(0.3, 0.3);
            menuItem.screenCenter(X);
            menuItem.ID = i;
            grpSelection.add(menuItem);
        }

        var versii:FlxText = new FlxText(5, FlxG.height - 24, 0, 'v${Lib.application.meta.get('version')}' , 12);
        versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(versii);

        changeSelection();
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
            changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);

        if (FlxG.keys.justPressed.ENTER) {
            switch (curSelected) {
                case 0:
                    FlxG.switchState(PlayState.new);
                case 1:
                    trace('options menu unfinished sorry');
                case 2:
                    Sys.exit(0);
            }
        }
	}

    function changeSelection(change:Int = 0) {
        curSelected += change;

        if (curSelected < 0)
            curSelected = grpSelection.length - 1;
        if (curSelected >= grpSelection.length)
            curSelected = 0;

        grpSelection.forEach((spr:FlxSprite) -> {
            spr.color = (spr.ID == curSelected) ? FlxColor.LIME : FlxColor.WHITE;
        });
    }
}