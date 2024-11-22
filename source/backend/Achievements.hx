package backend;

typedef AchievementData = {
	public var name:String;
	public var desc:String;
	public var hint:String;
}

typedef AchievementStats = {
	public var date:Date;
	public var song:String;
}

class Achievements {
	public static var achievements:Array<String> = [];
	public static var achievementsMap:Map<String, Bool> = new Map();
	public static var achievementStatsMap:Map<String, AchievementStats> = new Map();

	public static function load() {
		if (FlxG.save.data.achievementsMap != null)
			achievementsMap = FlxG.save.data.achievementsMap;
		if (FlxG.save.data.achievementStatsMap != null)
			achievementStatsMap = FlxG.save.data.achievementStatsMap;

		FlxG.save.flush();

		var path:String = Paths.txt('achievements/achList');
		try {
			if (Paths.exists(path)) {
				var listContent:String = Paths.getText(path);
				var achievementsFound:Array<String> = listContent.split('\n');

				for (achievement in achievementsFound) {
					var achievementName = achievement.trim();

					if (achievementName != "") {
						achievements.push(achievementName);
						try {
							Json.parse(Paths.getText(Paths.json('achievements/$achievementName')));
							trace("Achievement '" + achievement + "' loaded");
						} catch (e:Dynamic) {
							trace('Error loading achievement: $e');
						}
					}
				}
			}
		} catch (e:Dynamic) {
			trace(e);
		}
	}

	public static function unlock(ach:String, stats:AchievementStats, ?onFinish:Void->Void) {
		if (!isUnlocked(ach)) {
			showAchievement(ach, onFinish);

			achievementsMap.set(ach, true);
			achievementStatsMap.set(ach, stats);
			FlxG.save.data.achievementsMap = achievementsMap;
			FlxG.save.data.achievementStatsMap = achievementStatsMap;
			FlxG.save.flush();

			trace('achievement earned: $ach!\nmore info:\n $stats');
		}
	}

	public static function isUnlocked(ach:String):Bool {
		return achievementsMap.exists(ach) && achievementsMap.get(ach);
	}

	public static function getStats(ach:String):AchievementStats {
		return if (achievementStatsMap.exists(ach)) achievementStatsMap.get(ach); else createStat();
	}

	public static function createStat(?date:Date, ?song:String) {
		var stat:AchievementStats = {
			date: date,
			song: song
		};

		return fixStat(stat);
	}

	public static function fixStat(stat:AchievementStats):AchievementStats {
		if (stat.date == null)
			stat.date = Date.now();
		if (stat.song == null)
			stat.song = 'None';

		return stat;
	}

	public static function forget(ach:String) {
		if (isUnlocked(ach)) {
			achievementsMap.remove(ach);
			achievementStatsMap.remove(ach);
			FlxG.save.data.achievementsMap = achievementsMap;
			FlxG.save.data.achievementStatsMap = achievementStatsMap;
			FlxG.save.flush();

			trace('achievement $ach removed!');
		}
	}

	public static function showAchievement(ach:String, onFinish:Void->Void) {
		var camAwards:FlxCamera = new FlxCamera(0, 0, 0, 0, 1);
		camAwards.bgColor.alpha = 0;
		FlxG.cameras.add(camAwards);

		var sprGroup:FlxSpriteGroup = new FlxSpriteGroup();
		sprGroup.cameras = [camAwards];

		var coolAchieve:AchievementData = cast Json.parse(File.getContent(Paths.json('achievements/$ach')));

		var achBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achBG.scrollFactor.set();
		sprGroup.add(achBG);

		var achIcon:FlxSprite = new FlxSprite(achBG.x + 10, achBG.y + 10).loadGraphic(Paths.image('achievements/$ach'));
		achIcon.setGraphicSize(Std.int(achIcon.width * (2 / 3)));
		achIcon.scrollFactor.set();
		achIcon.updateHitbox();
		sprGroup.add(achIcon);

		var achName:FlxText = new FlxText(achIcon.x + achIcon.width + 20, achIcon.y + 16, 280, coolAchieve.name, 16);
		achName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achName.scrollFactor.set();
		sprGroup.add(achName);

		var achTxt:FlxText = new FlxText(achName.x, achName.y + 32, 280, coolAchieve.desc, 16);
		achTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achTxt.scrollFactor.set();
		sprGroup.add(achTxt);

		var flash = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.WHITE);
		flash.scrollFactor.set();
		sprGroup.add(flash);

		var where = FlxG.state.subState != null ? FlxG.state.subState : FlxG.state;
		where.add(sprGroup);

		FlxG.sound.play(Paths.sound('start'));

		FlxTween.tween(flash, {alpha: 0}, 0.65, {
			onComplete: (twn:FlxTween) -> {
				sprGroup.remove(flash);
			}
		});

		new FlxTimer().start(2.5, (tmr:FlxTimer) -> {
			FlxTween.tween(sprGroup, {alpha: 0}, 1, {
				onComplete: (twn:FlxTween) -> {
					sprGroup.kill();
					sprGroup.destroy();
					if (onFinish != null)
						onFinish();
					FlxG.cameras.remove(camAwards);
				}
			});
		});
	}
}