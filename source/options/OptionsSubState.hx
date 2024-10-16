package options;

import options.Option;

class OptionsSubState extends ExtendableSubState {
	var options:Array<Option>;
	var grpOptions:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var description:FlxText;
	var camFollow:FlxObject;

	var holdTimer:FlxTimer;
	var holdDirection:Int = 0;

	public function new() {
		super();

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);
		add(camFollow);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length) {
			var optionTxt:FlxText = new FlxText(20, 20 + (i * 50), 0, options[i].toString(), 32);
			optionTxt.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionTxt.ID = i;
			grpOptions.add(optionTxt);
		}

		description = new FlxText(0, FlxG.height * 0.1, FlxG.width * 0.9, '', 28);
		description.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.scrollFactor.set();
		add(description);

		changeSelection();

		holdTimer = new FlxTimer();

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		if (Input.justPressed('right') || Input.justPressed('left')) {
			if (options[curSelected].type != OptionType.Function) {
				changeValue(Input.justPressed('right') ? 1 : -1);
				startHold(Input.justPressed('right') ? 1 : -1);
			}
		}

		if (Input.justReleased('right') || Input.justReleased('left')) {
			if (holdTimer.active)
				holdTimer.cancel();
		}

		if (Input.justPressed('accept')) {
			final option:Option = options[curSelected];
			if (option != null)
				option.execute();
		}

		if (Input.justPressed('exit')) {
			SaveData.saveSettings();
			close();
		}
	}

	private function changeSelection(change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		grpOptions.forEach(function(txt:FlxText) {
			txt.alpha = (txt.ID == curSelected) ? 1 : 0.6;
			if (txt.ID == curSelected)
				camFollow.y = txt.y;
		});

		var option = options[curSelected];

		if (option.desc != null) {
			description.text = option.desc;
			description.screenCenter(X);
		}
	}

	private function changeValue(direction:Int = 0):Void {
		final option:Option = options[curSelected];

		if (option != null) {
			option.changeValue(direction);

			grpOptions.forEach(function(txt:FlxText):Void {
				if (txt.ID == curSelected)
					txt.text = option.toString();
			});
		}
	}

	private function startHold(direction:Int = 0):Void {
		holdDirection = direction;

		final option:Option = options[curSelected];

		if (option != null) {
			if (option.type != OptionType.Function)
				changeValue(holdDirection);

			switch (option.type) {
				case OptionType.Integer(_, _, _) | OptionType.Decimal(_, _, _):
					if (!holdTimer.active) {
						holdTimer.start(0.5, function(timer:FlxTimer):Void {
							timer.start(0.05, function(timer:FlxTimer):Void {
								changeValue(holdDirection);
							}, 0);
						});
					}
				default:
					// nothing
			}
		}
	}

	public function addOption(option:Option) {
		if (options == null || options.length < 1) options = [];
		options.push(option);
		return option;
	}
}