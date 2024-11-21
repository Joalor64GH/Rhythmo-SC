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

	override function update(elapsed:Float) {
		super.update(elapsed);
		x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 760, Utilities.boundTo(elapsed * lerpSpeed, 0, 1));
	}
}

class SongSelectState extends ExtendableState {
	var bg:FlxSprite;
	var coverGrp:FlxTypedGroup<Cover>;

	var currentIndex:Int = 0;
	var songListData:BasicData;

	var titleTxt:FlxText;
	var panelTxt:FlxText;
	var tinyTxt:FlxText;
	var bottomPanel:FlxSprite;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var isResetting:Bool = false;
	var lockInputs:Bool = false;

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
			} catch (e:Dynamic) {
				trace('Error getting credit icon: $e');
				newItem.loadGraphic(Paths.image('covers/placeholder'));
			}
			newItem.scale.set(0.6, 0.6);
			newItem.ID = i;
			coverGrp.add(newItem);
		}

		bottomPanel = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.6;
		add(bottomPanel);

		panelTxt = new FlxText(bottomPanel.x, bottomPanel.y + 8, FlxG.width, "", 32);
		panelTxt.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		panelTxt.scrollFactor.set();
		panelTxt.screenCenter(X);
		add(panelTxt);

		tinyTxt = new FlxText(panelTxt.x, panelTxt.y + 50, FlxG.width, Localization.get("tinyGuide", SaveData.settings.lang), 22);
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

		changeSelection(0, false);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (!isResetting)
			panelTxt.text = Localization.get("scoreTxt", SaveData.settings.lang) + lerpScore + " // " + Localization.get("diffTxt", SaveData.settings.lang)
				+ Std.string(songListData.songs[currentIndex].diff) + "/5";

		if (!lockInputs) {
			if (Input.justPressed('left') || Input.justPressed('right'))
				changeSelection(Input.justPressed('left') ? -1 : 1);

			if (Input.justPressed('accept'))
				openPlayState(currentIndex);
		}

		if (Input.justPressed('exit')) {
			if (!isResetting)
				ExtendableState.switchState(new MenuState());
			else {
				isResetting = false;
				lockInputs = false;
				titleTxt.color = FlxColor.WHITE;
				titleTxt.text = songListData.songs[currentIndex].name;
				panelTxt.text = Localization.get("scoreTxt", SaveData.settings.lang) + lerpScore + " // "
					+ Localization.get("diffTxt", SaveData.settings.lang) + Std.string(songListData.songs[currentIndex].diff) + "/5";
				tinyTxt.text = Localization.get("tinyGuide", SaveData.settings.lang);
			}
			FlxG.sound.play(Paths.sound('cancel'));
		}

		if (Input.justPressed('reset')) {
			if (Input.pressed('space')) {
				var randomSong:Int = FlxG.random.int(0, songListData.songs.length - 1);
				openPlayState(randomSong);
			} else {
				if (!isResetting) {
					isResetting = true;
					lockInputs = true;
					titleTxt.text = Localization.get("youDecide", SaveData.settings.lang);
					titleTxt.color = FlxColor.RED;
					panelTxt.text = Localization.get("confirmReset", SaveData.settings.lang);
					tinyTxt.text = '';
				} else {
					FlxG.sound.play(Paths.sound('erase'));
					titleTxt.text = Localization.get("confirmedReset", SaveData.settings.lang);
					tinyTxt.text = '';
					HighScore.resetSong(songListData.songs[currentIndex].name);
					isResetting = false;
					new FlxTimer().start(1, function(tmr:FlxTimer) {
						lockInputs = false;
						titleTxt.color = FlxColor.WHITE;
						titleTxt.text = songListData.songs[currentIndex].name;
						panelTxt.text = Localization.get("scoreTxt", SaveData.settings.lang) + lerpScore + " // "
							+ Localization.get("diffTxt", SaveData.settings.lang) + Std.string(songListData.songs[currentIndex].diff) + "/5";
						tinyTxt.text = Localization.get("tinyGuide", SaveData.settings.lang);
						changeSelection();
					});
				}
			}
		}
	}

	function openPlayState(index:Int) {
		try {
			PlayState.song = Song.loadSongfromJson(Paths.formatToSongPath(songListData.songs[index].name));
			ExtendableState.switchState(new PlayState());
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
		} catch (e)
			trace(e);
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		currentIndex = FlxMath.wrap(currentIndex + change, 0, songListData.songs.length - 1);
		for (num => item in coverGrp) {
			item.posX = num++ - currentIndex;
			item.alpha = (item.ID == currentIndex) ? 1 : 0.6;
		}

		titleTxt.text = songListData.songs[currentIndex].name;
		intendedScore = HighScore.getScore(songListData.songs[currentIndex].name);
	}
}