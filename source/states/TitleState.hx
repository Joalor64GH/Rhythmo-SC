package states;

class TitleState extends ExtendableState {
    var logo:FlxSprite;

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/title_bg'));
		add(bg);

        var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		var logo:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('title/logo'));
		logo.scale.set(0.4, 0.4);
        logo.screenCenter();
		add(logo);

        var text:FlxText = new FlxText(0, logo.y + 30, 0, "Press ENTER to Start!", 12);
		text.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

        if (Input.is("accept")) {
            FlxG.sound.play(Paths.sound('select'));
            FlxG.camera.flash(FlxColor.WHITE, 1);
            new FlxTimer().start(1, (tmr:FlxTimer) -> {
                transitionState(new MenuState());
            });
        }
	}
}