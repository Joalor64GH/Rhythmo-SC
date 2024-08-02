package states;

class MenuState extends ExtendableState {
	var curSelected:Int = 0;
	var grpSelection:FlxTypedGroup<FlxSprite>;
	var selections:Array<String> = ['play', 'options', 'exit'];

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/title_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpSelection = new FlxTypedGroup<FlxSprite>();
		add(grpSelection);

		for (i in 0...selections.length) {
			var menuItem:FlxSprite = new FlxSprite(0, i * 190).loadGraphic(Paths.image('title/' + selections[i]));
			menuItem.scale.set(0.4, 0.4);
			menuItem.screenCenter(X);
			menuItem.ID = i;
			grpSelection.add(menuItem);
		}

		var versii:FlxText = new FlxText(5, FlxG.height - 24, 0, 'v${Lib.application.meta.get('version')}', 12);
		versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versii);

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.is("up") || Input.is("down"))
			changeSelection(Input.is("up") ? -1 : 1);

		if (Input.is("accept")) {
			if (selections[curSelected] == 'exit') {
				FlxG.sound.play(Paths.sound('cancel'));
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
						case 'options':
							ExtendableState.switchState(new OptionsState());
					}
				});
			}
		}

		if (Input.is("exit")) {
			ExtendableState.switchState(new TitleState());
			FlxG.sound.play(Paths.sound('cancel'));
		}

		#if desktop
		if (Input.is("seven")) {
			ExtendableState.switchState(new EditorState());
		}
		#end
	}

	function changeSelection(change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, selections.length - 1);
		FlxG.sound.play(Paths.sound('scroll'));
		grpSelection.forEach((spr:FlxSprite) -> {
			spr.alpha = (spr.ID == curSelected) ? 1 : 0.6;
		});
	}
}