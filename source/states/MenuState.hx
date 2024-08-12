package states;

class MenuState extends ExtendableState {
	var bg:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var camMain:FlxCamera;

	var curSelected:Int = 0;
	var grpSelection:FlxTypedGroup<FlxSprite>;
	var selections:Array<String> = ['play', 'credits', 'options', 'exit'];

	override function create() {
		super.create();

		camMain = new FlxCamera();
		FlxG.cameras.reset(camMain);
		FlxG.cameras.setDefaultDrawTarget(camMain, true);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		var yScroll:Float = Math.max(0.25 - (0.05 * (selections.length - 4)), 0.1);
		bg = new FlxSprite().loadGraphic(Paths.image('title/title_bg'));
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.scrollFactor.set(0, yScroll / 3);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpSelection = new FlxTypedGroup<FlxSprite>();
		add(grpSelection);

		for (i in 0...selections.length) {
			var menuItem:FlxSprite = new FlxSprite(0, i * 190).loadGraphic(Paths.image('title/' + selections[i]));
			menuItem.scale.set(0.4, 0.4);
			menuItem.screenCenter();
			menuItem.updateHitbox();
			menuItem.scrollFactor.set(0, Math.max(0.25 - (0.05 * (selections.length - 4)), 0.1));
			menuItem.ID = i;
			grpSelection.add(menuItem);
		}

		var versii:FlxText = new FlxText(5, FlxG.height - 24, 0, 'v${Lib.application.meta.get('version')}', 12);
		versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versii.scrollFactor.set(0, Math.max(0.25 - (0.05 * (selections.length - 4)), 0.1));
		add(versii);

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var lerpVal:Float = boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
	
		var mult:Float = FlxMath.lerp(1.07, bg.scale.x, boundTo(1 - (elapsed * 9), 0, 1));
		bg.scale.set(mult, mult);
		bg.updateHitbox();
		bg.offset.set();

		if (Input.is("up") || Input.is("down"))
			changeSelection(Input.is("up") ? -1 : 1);

		if (Input.is("accept")) {
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

		var add:Float = (grpSelection.members[curSelected].length > 3 ? grpSelection.members[curSelected].length * 8 : 0);
		camFollow.setPosition(grpSelection.members[curSelected].getGraphicMidpoint().x, grpSelection.members[curSelected].getGraphicMidpoint().y - add);
	}

	function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}
}