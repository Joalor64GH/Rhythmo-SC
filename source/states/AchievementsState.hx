package states;

import backend.Achievements;

class AchievementsState extends ExtendableState {
	var stat:AchievementStats;
	var achievementArray:Array<AchievementData> = [];
	var achievementGrp:FlxTypedGroup<FlxText>;
	var iconGrp:FlxTypedGroup<AchievementIcon>;
	var isUnlocked:Array<Bool> = [];
	var description:FlxText;
	var curSelected:Int = 0;
	var camFollow:FlxObject;

	override function create() {
		super.create();

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		var mouseSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('cursor/cursor'));
		FlxG.mouse.load(mouseSpr.pixels);

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);
		add(camFollow);

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/backgrounds/achievements_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		achievementGrp = new FlxTypedGroup<FlxText>();
		add(achievementGrp);

		iconGrp = new FlxTypedGroup<AchievementIcon>();
		add(iconGrp);

		initAchievementData();

		description = new FlxText(0, FlxG.height * 0.1, FlxG.width * 0.9, '', 28);
		description.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.scrollFactor.set();
		add(description);

		var guideTxt:FlxText = new FlxText(5, FlxG.height - 24, 0, 'Press R to reset the currently selected achievement. Press ALT + R to reset all achievements.', 12);
		guideTxt.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		guideTxt.scrollFactor.set();
		add(guideTxt);

		changeSelection(0, false);

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		if (Input.justPressed('exit')) {
			FlxG.sound.play(Paths.sound('cancel'));
			ExtendableState.switchState(new MenuState());
		}

		if (Input.justPressed('reset')) {
			FlxG.mouse.visible = true;
			if (Input.pressed('alt')) {
				openSubState(new PromptSubState('This action will reset ALL of the achievements.\nProceed anyways?', () -> {
					FlxG.mouse.visible = false;
					FlxG.sound.play(Paths.sound('select'));
					for (i in 0...achievementArray.length) {
						var formattedName:String = StringTools.replace(achievementArray[i].name.toLowerCase(), " ", "_");
						Achievements.forget(formattedName);
					}
					regenList();
				}, () -> {
					FlxG.mouse.visible = false;
					FlxG.sound.play(Paths.sound('cancel'));
				}));
			} else {
				openSubState(new PromptSubState('This action will reset the selected achievement.\nProceed anyways?', () -> {
					FlxG.mouse.visible = false;
					FlxG.sound.play(Paths.sound('select'));
					var formattedName:String = StringTools.replace(achievementArray[curSelected].name.toLowerCase(), " ", "_");
					Achievements.forget(formattedName);
					regenList();
				}, () -> {
					FlxG.mouse.visible = false;
					FlxG.sound.play(Paths.sound('cancel'));
				}));
			}
		}
	}

	function initAchievementData() {
		for (i in 0...Achievements.achievements.length) {
			var coolAchieve:AchievementData = cast Json.parse(File.getContent(Paths.json('achievements/' + Achievements.achievements[i])));
			achievementArray.push(coolAchieve);

			var stringToUse:String = coolAchieve.name;
			var unlocked:Bool = true;

			if (!Achievements.achievementsMap.exists(Achievements.achievements[i])) {
				stringToUse = "???";
				unlocked = false;
			}

			isUnlocked.push(unlocked);

			var text:FlxText = new FlxText(20, 60 + (i * 80), stringToUse, 32);
			text.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.ID = i;
			achievementGrp.add(text);

			var icon:AchievementIcon = new AchievementIcon(0, 0, Achievements.achievements[i].trim());
			icon.sprTracker = text;
			iconGrp.add(icon);
		}
	}

	function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, achievementArray.length - 1);

		achievementGrp.forEach(function(txt:FlxText) {
			txt.alpha = (txt.ID == curSelected) ? 1 : 0.6;
			if (txt.ID == curSelected)
				camFollow.y = txt.y;
		});

		var formattedName:String = StringTools.replace(achievementArray[curSelected].name.toLowerCase(), " ", "_");

		stat = Achievements.getStats(formattedName);
		if (achievementArray[curSelected].desc != null || achievementArray[curSelected].hint != null) {
			description.text = Achievements.isUnlocked(formattedName) ? achievementArray[curSelected].desc
				+ '\nHint: '
				+ achievementArray[curSelected].hint
					+ '\nDate Unlocked: '
					+ stat.date
					+ '\nSong Unlocked: '
					+ stat.song : 'This achievement has not been unlocked yet!'
				+ '\nHint: '
				+ achievementArray[curSelected].hint;
			description.screenCenter(X);
		}
	}

	function regenList() {
		achievementArray = [];
		isUnlocked = [];

		achievementGrp.forEach(ach -> {
			achievementGrp.remove(ach, true);
			ach.destroy();
		});
		iconGrp.forEach(icon -> {
			iconGrp.remove(icon, true);
			icon.destroy();
		});

		achievementGrp.clear();
		iconGrp.clear();

		initAchievementData();
		changeSelection(0, false);
	}
}

class AchievementIcon extends GameSprite {
	public var sprTracker:FlxSprite;

	public function new(x:Float, y:Float, ach:String) {
		super(x, y);

		if (Achievements.isUnlocked(ach)) {
			try {
				loadGraphic(Paths.image('achievements/$ach'));
			} catch (e:Dynamic) {
				trace('Error getting achievement icon: $e');
				loadGraphic(Paths.image('achievements/unknown'));
			}
		} else
			loadGraphic(Paths.image('achievements/locked'));

		setGraphicSize(75, 75);
		scrollFactor.set();
		updateHitbox();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y);
			scrollFactor.set(sprTracker.scrollFactor.x, sprTracker.scrollFactor.y);
		}
	}
}