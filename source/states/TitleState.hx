package states;

class TitleState extends ExtendableState {
	var lockInputs:Bool = false;
	var hueShader:HueDisplacer;

	override function create() {
		super.create();

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		hueShader = new HueDisplacer();

		#if FUTURE_POLYMOD
		if (ModHandler.trackedMods.length > 0) {
			var installedMods:Array<String> = ModHandler.getModIDs();
			Main.toast.create('Mods Installed:', 0xFFFFFF00, installedMods.join('\n'));
		}
		#end

		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/backgrounds/title_bg'));
		bg.shader = hueShader.shader;
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		var audio:AudioDisplay = new AudioDisplay(FlxG.sound.music, 0, FlxG.height, FlxG.width, FlxG.height, 200, FlxColor.LIME);
		add(audio);

		var logo:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/title/logo'));
		logo.shader = hueShader.shader;
		logo.scale.set(0.7, 0.7);
		logo.screenCenter();
		logo.angle = -4;
		add(logo);
		
		FlxTween.tween(logo, {y: logo.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});

		new FlxTimer().start(0.01, (tmr:FlxTimer) -> {
			if (logo.angle == -4)
				FlxTween.angle(logo, logo.angle, 4, 4, {ease: FlxEase.quartInOut});
			if (logo.angle == 4)
				FlxTween.angle(logo, logo.angle, -4, 4, {ease: FlxEase.quartInOut});
		}, 0);

		var text:FlxText = new FlxText(0, logo.y + 400, 0, Localization.get("pressEnter"), 12);
		text.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.pressed('left') || Input.pressed('right'))
			hueShader?.update(Input.pressed('left') ? elapsed * 0.1 : -elapsed * 0.1);

		if (Input.justPressed('accept') && !lockInputs) {
			lockInputs = true;
			FlxG.sound.play(Paths.sound('start'));
			if (SaveData.settings.flashing)
				FlxG.camera.flash(FlxColor.WHITE, 1);
			new FlxTimer().start(1, (tmr:FlxTimer) -> {
				ExtendableState.switchState(new MenuState());
			});
		}
	}
}