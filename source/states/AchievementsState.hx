package states;

import backend.Achievements;

class AchievementsState extends ExtendableState {
	var achievementArray:Array<AchievementData> = [];
	var achievementGrp:FlxTypedGroup<FlxText>;
	var iconArray:Array<AchievementIcon> = [];
	var isUnlocked:Array<Bool> = [];
	var description:FlxText;
	var curSelected:Int = 0;
	var camFollow:FlxObject;

	override function create() {
		super.create();

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);
		add(camFollow);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/achievements_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		achievementGrp = new FlxTypedGroup<FlxText>();
		add(achievementGrp);

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
			iconArray.push(icon);
			add(icon);
		}

		description = new FlxText(0, FlxG.height * 0.1, FlxG.width * 0.9, '', 28);
		description.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.scrollFactor.set();
		add(description);

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

		if (achievementArray[curSelected].desc != null || achievementArray[curSelected].hint != null) {
			description.text = Achievements.isUnlocked(achievementArray[curSelected].name.toLowerCase()) ? achievementArray[curSelected].desc
				+ '\nHint: '
				+ achievementArray[curSelected].hint : 'This achievement has not been unlocked yet!'
				+ '\nHint: '
				+ achievementArray[curSelected].hint;
			description.screenCenter(X);
		}
	}
}

class AchievementIcon extends GameSprite {
	public var sprTracker:FlxSprite;

	public function new(x:Float, y:Float, ach:String) {
		super(x, y);

		if (Achievements.isUnlocked(ach))
			loadGraphic(Paths.image('achievements/' + ach));
		else
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