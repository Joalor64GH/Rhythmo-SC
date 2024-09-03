package states;

typedef BasicData = {
	var songs:Array<SongArray>;
}

typedef SongArray = {
	var name:String;
	var diff:Float;
}

class Cover extends FlxSprite {
	public var lerpSpeed:Float = 6;
	public var posX:Float = 0;

	function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	override function update(elapsed:Float) {
		super.update(elapsed);
		x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 760, boundTo(elapsed * lerpSpeed, 0, 1));
	}
}

class SongSelectState extends ExtendableState {
	var bg:FlxSprite;
	var coverGrp:FlxTypedGroup<Cover>;

	var currentIndex:Int = 0;
	var songListData:BasicData;

	var panelTxt:FlxText;
	var tinyTxt:FlxText;
	var bottomPanel:FlxSprite;

	var titleTxt:FlxText;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var isResetting:Bool = false;
	var lockedInputs:Bool = false;

	override function create() {
		super.create();

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		songListData = Json.parse(Paths.getTextFromFile('songs.json'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/selector_bg'));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		coverGrp = new FlxTypedGroup<Cover>();
		add(coverGrp);

		for (i in 0...songListData.songs.length) {
			var newItem:Cover = new Cover();
			try {
				newItem.loadGraphic(Paths.image('covers/' + Paths.formatToSongPath(songListData.songs[i].name)));
			} catch (e) {
				trace("oops! cover returned null!");
				newItem.loadGraphic(Paths.image('covers/placeholder'));
			}
			newItem.scale.set(0.6, 0.6);
			newItem.ID = i;
			coverGrp.add(newItem);
		}

		bottomPanel = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.6;
		add(bottomPanel);

		panelTxt = new FlxText(bottomPanel.x, bottomPanel.y + 4, FlxG.width, "", 32);
		panelTxt.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		panelTxt.scrollFactor.set();
		panelTxt.screenCenter(X);
		add(panelTxt);

		tinyTxt = new FlxText(panelTxt.x, panelTxt.y + 50, FlxG.width, "Press R to reset the score of the currently selected song. // Press SPACE + R for a random song.", 22);
		tinyTxt.screenCenter(X);
		tinyTxt.scrollFactor.set();
		tinyTxt.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(tinyTxt);

		titleTxt = new FlxText(0, 0, FlxG.width, "", 32);
		titleTxt.setFormat(Paths.font('vcr.ttf'), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.scrollFactor.set();
		titleTxt.screenCenter(X);
		add(titleTxt);

		var arrows:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/arrows'));
		arrows.screenCenter(XY);
		add(arrows);

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, Math.exp(-elapsed * 24)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (!isResetting)
			panelTxt.text = Localization.get("scoreTxt", SaveData.settings.lang) + lerpScore + " // " + Localization.get("diffTxt", SaveData.settings.lang)
				+ Std.string(songListData.songs[currentIndex].diff) + "/5";

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var left = Input.is('left') || (gamepad != null ? Input.gamepadIs('gamepad_left') : false);
		var right = Input.is('right') || (gamepad != null ? Input.gamepadIs('gamepad_right') : false);
		var accept = Input.is('accept') || (gamepad != null ? Input.gamepadIs('gamepad_accept') : false);
		var accept2 = Input.is('space', PRESSED) || (gamepad != null ? Input.gamepadIs('start', PRESSED) : false);
		var exit = Input.is('exit') || (gamepad != null ? Input.gamepadIs('gamepad_exit') : false);
		var reset = Input.is('r') || (gamepad != null ? Input.gamepadIs('right_stick_click') : false);

		if (!lockedInputs) {
			if (left || right)
				changeSelection(left ? -1 : 1);
		}

		if (exit) {
			if (!isResetting) {
				ExtendableState.switchState(new MenuState());
				FlxG.sound.play(Paths.sound('cancel'));
			} else {
				FlxG.sound.play(Paths.sound('cancel'));
				titleTxt.color = FlxColor.WHITE;
				titleTxt.text = songListData.songs[currentIndex].name;
				panelTxt.text = Localization.get("scoreTxt", SaveData.settings.lang) + lerpScore + " // " + Localization.get("diffTxt", SaveData.settings.lang)
					+ Std.string(songListData.songs[currentIndex].diff) + "/5";
				tinyTxt.text = 'Press R to reset the score of the currently selected song. // Press SPACE + R for a random song.';
			}
		}

		if (accept) {
			PlayState.song = Song.loadSongfromJson(Paths.formatToSongPath(songListData.songs[currentIndex].name));
			ExtendableState.switchState(new PlayState());
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
		}

		if (reset) {
			if (accept2) {
				var randomSong:Int = FlxG.random.int(0, songListData.songs.length - 1);
				PlayState.song = Song.loadSongfromJson(Paths.formatToSongPath(songListData.songs[randomSong].name));
				ExtendableState.switchState(new PlayState());
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
			} else {
				if (!isResetting) {
					isResetting = true;
					lockedInputs = true;
					titleTxt.text = 'Are you sure?';
					titleTxt.color = FlxColor.RED;
					panelTxt.text = 'R - Confirm // ESCAPE - Cancel';
					tinyTxt.text = '';
				} else {
					FlxG.sound.play(Paths.sound('erase'));
					titleTxt.text = 'DATA DESTROYED';
					panelTxt.text = '';
					tinyTxt.text = '';
					HighScore.resetSong(songListData.songs[currentIndex].name);
					isResetting = false;
					new FlxTimer().start(1, function(tmr:FlxTimer) {
						lockedInputs = false;
						titleTxt.color = FlxColor.WHITE;
						titleTxt.text = songListData.songs[currentIndex].name;
						panelTxt.text = Localization.get("scoreTxt", SaveData.settings.lang) + lerpScore + " // " + Localization.get("diffTxt", SaveData.settings.lang)
							+ Std.string(songListData.songs[currentIndex].diff) + "/5";
						tinyTxt.text = 'Press R to reset the score of the currently selected song. // Press SPACE + R for a random song.';
						changeSelection();
					});
				}
			}
		}
	}

	private function changeSelection(i:Int = 0) {
		FlxG.sound.play(Paths.sound('scroll'));
		currentIndex = FlxMath.wrap(currentIndex + i, 0, songListData.songs.length - 1);
		for (num => item in coverGrp) {
			item.posX = num++ - currentIndex;
			item.alpha = (item.ID == currentIndex) ? 1 : 0.6;
		}

		titleTxt.text = songListData.songs[currentIndex].name;
		intendedScore = HighScore.getScore(songListData.songs[currentIndex].name);
	}
}