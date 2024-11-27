package options;

import options.Option;

class OptionsSubState extends ExtendableSubState {
	var options:Array<Option> = [];
	var grpOptions:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var description:FlxText;
	var camFollow:FlxObject;

	var holdTimer:FlxTimer;
	var holdDirection:Int = 0;

	public function new() {
		super();

		var option:Option = new Option(Localization.get("opAnti"), Localization.get("descAnti"), OptionType.Toggle, SaveData.settings.antialiasing);
		option.onChange = (value:Dynamic) -> SaveData.settings.antialiasing = value;
		options.push(option);

		#if desktop
		var option:Option = new Option(Localization.get("opFlScrn"), Localization.get("descFlScrn"), OptionType.Toggle, SaveData.settings.fullscreen);
		option.onChange = (value:Dynamic) -> {
			SaveData.settings.fullscreen = value;
			FlxG.fullscreen = SaveData.settings.fullscreen;
		};
		options.push(option);
		#end

		var option:Option = new Option(Localization.get("opFlash"), Localization.get("descFlash"), OptionType.Toggle, SaveData.settings.flashing);
		option.onChange = (value:Dynamic) -> SaveData.settings.flashing = value;
		options.push(option);

		var option:Option = new Option(Localization.get("opFrm"), Localization.get("descFrm"), OptionType.Integer(60, 240, 10),
			Std.int(FlxMath.bound(FlxG.stage.application.window.displayMode.refreshRate, 60, 240)));
		option.onChange = (value:Dynamic) -> {
			SaveData.settings.framerate = value;
			Main.updateFramerate(SaveData.settings.framerate);
		};
		options.push(option);

		var option:Option = new Option(Localization.get("opFPS"), Localization.get("descFPS"), OptionType.Toggle, SaveData.settings.fpsCounter);
		option.onChange = (value:Dynamic) -> {
			SaveData.settings.fpsCounter = value;
			if (Main.fpsDisplay != null)
				Main.fpsDisplay.visible = SaveData.settings.fpsCounter;
		};
		options.push(option);

		var option:Option = new Option(Localization.get("opSpeed"), Localization.get("descSpeed"), OptionType.Integer(1, 10, 1), SaveData.settings.songSpeed);
		option.onChange = (value:Dynamic) -> SaveData.settings.songSpeed = value;
		options.push(option);

		var option:Option = new Option(Localization.get("opDwnScrl"), Localization.get("descDwnScrl"), OptionType.Toggle, SaveData.settings.downScroll);
		option.onChange = (value:Dynamic) -> SaveData.settings.downScroll = value;
		options.push(option);

		var option:Option = new Option(Localization.get("opUnderlay"), Localization.get("descUnderlay"), OptionType.Integer(0, 100, 1),
			SaveData.settings.laneUnderlay);
		option.showPercentage = true;
		option.onChange = (value:Dynamic) -> SaveData.settings.laneUnderlay = value;
		options.push(option);

		var option:Option = new Option(Localization.get("opHitSndT"), Localization.get("descHitSndT"), OptionType.Choice(['Default', 'CD', 'OSU', 'Switch']),
			SaveData.settings.hitSoundType);
		option.onChange = (value:Dynamic) -> {
			SaveData.settings.hitSoundType = value;
			FlxG.sound.play(Paths.sound('hitsound' + SaveData.settings.hitSoundType));
		};
		options.push(option);

		var option:Option = new Option(Localization.get("opHitSndV"), Localization.get("descHitSndV"), OptionType.Integer(0, 100, 10),
			SaveData.settings.hitSoundVolume);
		option.showPercentage = true;
		option.onChange = (value:Dynamic) -> {
			SaveData.settings.hitSoundVolume = value;
			FlxG.sound.play(Paths.sound('hitsound' + SaveData.settings.hitSoundType), SaveData.settings.hitSoundVolume / 100);
		};
		options.push(option);

		var option:Option = new Option(Localization.get("opBot"), Localization.get("descBot"), OptionType.Toggle, SaveData.settings.botPlay);
		option.onChange = (value:Dynamic) -> SaveData.settings.botPlay = value;
		options.push(option);

		var option:Option = new Option(Localization.get("opMSDisp"), Localization.get("descMSDisp"), OptionType.Toggle, SaveData.settings.displayMS);
		option.onChange = (value:Dynamic) -> SaveData.settings.displayMS = value;
		options.push(option);

		var option:Option = new Option(Localization.get("opMash"), Localization.get("descMash"), OptionType.Toggle, SaveData.settings.antiMash);
		option.onChange = (value:Dynamic) -> SaveData.settings.antiMash = value;
		options.push(option);

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
			var optionTxt:FlxText = new FlxText(20, 20 + (i * 80), 0, options[i].toString(), 32);
			optionTxt.setFormat(Paths.font('main.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionTxt.ID = i;
			grpOptions.add(optionTxt);
		}

		description = new FlxText(0, FlxG.height * 0.1, FlxG.width * 0.9, '', 28);
		description.setFormat(Paths.font('main.ttf'), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.scrollFactor.set();
		add(description);

		changeSelection(0, false);

		holdTimer = new FlxTimer();

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		if (Input.justPressed('right') || Input.justPressed('left'))
			startHold(Input.justPressed('right') ? 1 : -1);

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
			persistentDraw = persistentUpdate = true;
			close();
		}
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
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
		FlxG.sound.play(Paths.sound('scroll'));
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
}