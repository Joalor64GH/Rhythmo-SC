package states;

class MenuState extends ExtendableState {
	var curSelected:Int = 0;
	var grpSelection:FlxTypedGroup<FlxSprite>;
	var selections:Array<String> = ['play', #if FUTURE_POLYMOD 'mods', #end 'credits', 'options', 'exit'];

	var accepted:Bool = false;
	var allowInputs:Bool = false;

	var camFollow:FlxObject;

	override function create() {
		super.create();

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/title_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpSelection = new FlxTypedGroup<FlxSprite>();
		add(grpSelection);

		for (i in 0...selections.length) {
			var menuItem:FlxSprite = new FlxSprite(0, (i * 160) + (108 - (Math.max(selections.length, 4) - 4) * 80)).loadGraphic(Paths.image('menu/mainmenu/' + selections[i]));
			menuItem.scale.set(0.4, 0.4);
			menuItem.screenCenter(X);
			menuItem.ID = i;
			grpSelection.add(menuItem);
		}

		var versii:FlxText = new FlxText(5, FlxG.height - 24, 0, 'v${Lib.application.meta.get('version')}', 12);
		versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versii.scrollFactor.set();
		add(versii);

		changeSelection();

		allowInputs = true;

		FlxG.camera.follow(camFollow, LOCKON, 0.25);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var up = Input.is('up') || (gamepad != null ? Input.gamepadIs('gamepad_up') : false);
		var down = Input.is('down') || (gamepad != null ? Input.gamepadIs('gamepad_down') : false);
		var accept = Input.is('accept') || (gamepad != null ? Input.gamepadIs('gamepad_accept') : false);
		var exit = Input.is('exit') || (gamepad != null ? Input.gamepadIs('gamepad_exit') : false);

		if (allowInputs) {
			if (up || down && !accepted)
				changeSelection(up ? -1 : 1);

			if (accept && !accepted) {
				accepted = true;
				if (selections[curSelected] == 'exit') {
					FlxG.sound.play(Paths.sound('cancel'));
					if (FlxG.sound.music != null)
						FlxG.sound.music.fadeOut(0.3);
					FlxG.camera.fade(FlxColor.BLACK, 0.5, false, () -> {
						#if sys
						Sys.exit(0);
						#else
						System.exit(0);
						#end
					});
				} else {
					FlxG.sound.play(Paths.sound('select'));
					if (SaveData.settings.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					new FlxTimer().start(1, (tmr:FlxTimer) -> {
						switch (selections[curSelected]) {
							case 'play':
								ExtendableState.switchState(new SongSelectState());
							#if FUTURE_POLYMOD
							case 'mods':
								if (ModHandler.trackedMods != [])
									ExtendableState.switchState(new ModsState());
								else {
									accepted = false;
									allowInputs = true;
									Main.toast.create('No Mods Installed!', 0xFFFFFF00, 'Please add mods to be able to access the menu!');
								}
							#end
							case 'credits':
								ExtendableState.switchState(new CreditsState());
							case 'options':
								ExtendableState.switchState(new OptionsState());
						}
					});
				}
			}

			if (exit && !accepted) {
				ExtendableState.switchState(new TitleState());
				FlxG.sound.play(Paths.sound('cancel'));
			}

			#if desktop
			if (Input.is("seven") && !accepted)
				ExtendableState.switchState(new EditorState());
			#end
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, selections.length - 1);
		FlxG.sound.play(Paths.sound('scroll'));
		grpSelection.forEach((spr:FlxSprite) -> {
			spr.alpha = (spr.ID == curSelected) ? 1 : 0.6;
			if (spr.ID == curSelected)
				camFollow.y = spr.y;
		});
	}
}