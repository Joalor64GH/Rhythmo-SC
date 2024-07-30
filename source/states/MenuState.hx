package states;

class MenuState extends ExtendableState {
	var curSelected:Int = 0;
	var grpSelection:FlxTypedGroup<FlxSprite>;
	var selections:Array<String> = ['play', 'options', 'exit'];

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/title_bg'));
		add(bg);

		var grid:CustomBackdrop = new CustomBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
        grid.velocity.set(40, 0);
        grid.setOscillation(2, 10);
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
			if (curSelected == 2) {
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
				if (SaveData.settings.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
				new FlxTimer().start(1, (tmr:FlxTimer) -> {
					switch (curSelected) {
						case 0:
							ExtendableState.switchState(new SongSelectState());
						case 1:
							ExtendableState.switchState(new OptionsState());
					}
				});
			}
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