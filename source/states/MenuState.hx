package states;

class MenuState extends ExtendableState {
	var curSelected:Int = 0;
	var grpSelection:FlxTypedGroup<FlxSprite>;
	var selections:Array<String> = ['play', 'credits', 'options', 'exit'];

	var accepted:Bool = false;
	var allowInputs:Bool = false;

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/title_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpSelection = new FlxTypedGroup<FlxSprite>();
		add(grpSelection);

		for (i in 0...selections.length) {
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)).loadGraphic(Paths.image('menu/mainmenu/' + selections[i]));
			menuItem.scale.set(0.4, 0.4);
			menuItem.screenCenter(X);
			menuItem.ID = i;
			grpSelection.add(menuItem);
		}

		var versii:FlxText = new FlxText(5, FlxG.height - 24, 0, 'v${Lib.application.meta.get('version')}', 12);
		versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versii);

		changeSelection();

		allowInputs = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (allowInputs) {
			if (Input.is("up") || Input.is("down") && !accepted)
				changeSelection(Input.is("up") ? -1 : 1);

			if (Input.is("accept") && !accepted) {
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
							case 'credits':
								ExtendableState.switchState(new CreditsState());
							case 'options':
								ExtendableState.switchState(new OptionsState());
						}
					});
				}
			}

			if (Input.is("exit") && !accepted) {
				ExtendableState.switchState(new TitleState());
				FlxG.sound.play(Paths.sound('cancel'));
			}

			#if desktop
			if (Input.is("seven") && !accepted) {
				ExtendableState.switchState(new EditorState());
			}
			#end
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, selections.length - 1);
		FlxG.sound.play(Paths.sound('scroll'));
		grpSelection.forEach((spr:FlxSprite) -> {
			spr.alpha = (spr.ID == curSelected) ? 1 : 0.6;
		});
	}
}