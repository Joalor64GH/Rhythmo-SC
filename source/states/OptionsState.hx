package states;

class OptionsState extends FlxState {
	final options:Array<String> = ["FPS Counter", "Fullscreen", "Antialiasing", "Framerate", "Controls", "Language"];
	var grpOptions:FlxTypedGroup<FlxText>;

	var curSelected:Int = 0;
	var camObject:FlxObject;

	var notSelectedAlpha:Float = 0.55;

	override function create() {
		super.create();

		camObject = new FlxObject(80, 0, 0, 0);
		camObject.screenCenter(X);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('options/options_bg'));
		bg.scrollFactor.set();
		add(bg);

		var grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x2C00FF95, 0x0));
		grid.scrollFactor.set();
		grid.velocity.set(25, 25);
		add(grid);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length) {
			var text = new FlxText(80, 40 + (60 * i), 0, options[i], 20);
			text.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.alpha = notSelectedAlpha;
			grpOptions.add(text);
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

	function changeItem(number:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + number, 0, options.length - 1);
		
		for (i in grpOptions.members)
			i.alpha = (i.ID == curSelected) ? 1.0 : notSelectedAlpha;

		camObject.y = grpOptions.members[curSelected].y;
		
		FlxG.sound.play(Paths.sound('scroll'));
	}
}