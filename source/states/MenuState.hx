package states;

class MenuState extends ExtendableState {
	var curSelected:Int = 0;
	var grpSelection:FlxTypedGroup<FlxSprite>;
	var selections:Array<String> = [];

	var lockInputs:Bool = false;

	var camFollow:FlxObject;

	override function create() {
		super.create();

		var path:String = Paths.txt('menuList');
		if (Paths.exists(path)) {
			try {
				var menuArray:Array<String> = Paths.getTextArray(path);
				for (i in 0...menuArray.length)
					selections = menuArray;

				trace('menu options are: ${menuArray.join(',')}');

				#if !FUTURE_POLYMOD
				if (selections.contains('mods'))
					selections.remove('mods');
				#end
			} catch (e:Dynamic) {
				trace("Error!\n" + e);
				selections = [
					'play',
					#if FUTURE_POLYMOD
					'mods',
					#end
					'awards',
					'credits',
					'options',
					'exit'
				];
			}
		} else {
			selections = [
				'play',
				#if FUTURE_POLYMOD
				'mods',
				#end
				'awards',
				'credits',
				'options',
				'exit'
			];
		}

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (!FlxG.sound.music.playing #if FUTURE_POLYMOD || ModsState.mustResetMusic #end) {
			FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
			#if FUTURE_POLYMOD
			ModsState.mustResetMusic = false;
			#end
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		add(camFollow);

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
			var menuItem:FlxSprite = new GameSprite(0, (i * 160) + (108 - (Math.max(selections.length, 4) - 4) * 80));
			menuItem.loadGraphic(Paths.image('menu/mainmenu/' + selections[i]));
			menuItem.scale.set(0.4, 0.4);
			menuItem.screenCenter(X);
			menuItem.ID = i;
			grpSelection.add(menuItem);
		}

		final versii:FlxText = new FlxText(5, FlxG.height - 30, 0, 'Rhythmo v${Lib.application.meta.get('version')}'
			#if debug + ' (${MacrosUtil.getCommitId()})' #end, 12);
		versii.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versii.scrollFactor.set();
		add(versii);

		changeSelection(0, false, false);

		var curDate = Date.now();
		if (curDate.getDay() == 5 && curDate.getHours() >= 18)
			Achievements.unlock('freaky_friday', {
				date: Date.now(),
				song: 'None'
			}, () -> {
				trace('getting freaky on a friday night yeah');
			});

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!lockInputs) {
			if (Input.justPressed('up') || Input.justPressed('down'))
				changeSelection(Input.justPressed('up') ? -1 : 1);

			if (Input.justPressed('accept')) {
				lockInputs = true;
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
								if (ModHandler.trackedMods.length > 0) ExtendableState.switchState(new ModsState()); else {
									lockInputs = false;
									Main.toast.create('No Mods Installed!', 0xFFFFFF00, 'Please add mods to be able to access the menu!');
								}
							#end
							case 'awards':
								ExtendableState.switchState(new AchievementsState());
							case 'credits':
								ExtendableState.switchState(new CreditsState());
							case 'options':
								ExtendableState.switchState(new options.OptionsState());
							default:
								ExtendableState.switchState(new ScriptedState(selections[curSelected], []));
						}
					});
				}
			}

			if (Input.justPressed('exit')) {
				ExtendableState.switchState(new TitleState());
				FlxG.sound.play(Paths.sound('cancel'));
			}

			#if desktop
			if (Input.justPressed('seven'))
				ExtendableState.switchState(new EditorState());
			#end
		}
	}

	function changeSelection(change:Int = 0, ?doZoomThing:Bool = true, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, selections.length - 1);
		grpSelection.forEach((spr:FlxSprite) -> {
			spr.alpha = (spr.ID == curSelected) ? 1 : 0.6;
			if (spr.ID == curSelected) {
				camFollow.y = spr.getGraphicMidpoint().y;
				if (doZoomThing) {
					spr.scale.set(0.5, 0.5);
					FlxTween.cancelTweensOf(spr.scale);
					FlxTween.tween(spr.scale, {x: 0.4, y: 0.4}, 0.3, {ease: FlxEase.quadOut});
				}
			}
		});
	}
}