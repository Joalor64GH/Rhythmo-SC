package substates;

class ResultsSubState extends ExtendableSubState {
	var bg:FlxSprite;
	var rankSpr:FlxSprite;
	var rankTxt:FlxText;
	var anyKeyTxt:FlxText;

	var tweens:Array<FlxTween> = [];

	public function new(rank:String, score:Int, accuracy:Float) {
		super();

		persistentUpdate = true;

		bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		bg.alpha = 0;
		add(bg);

		rankSpr = new FlxSprite(700, 0).loadGraphic(Paths.image('gameplay/rankings/' + rank.toLowerCase()));
		rankSpr.screenCenter(Y);
		rankSpr.alpha = 0;
		if (rank != "?") add(rankSpr);

		rankSpr.angle = -4;

		new FlxTimer().start(0.01, (tmr:FlxTimer) -> {
			if (rankSpr.angle == -4)
				tweens.push(FlxTween.angle(rankSpr, rankSpr.angle, 4, 4, {ease: FlxEase.quartInOut}));
			if (rankSpr.angle == 4)
				tweens.push(FlxTween.angle(rankSpr, rankSpr.angle, -4, 4, {ease: FlxEase.quartInOut}));
		}, 0);

		rankTxt = new FlxText(10, 300, FlxG.width, "RESULTS\nScore: " + score + "\nAccuracy: " + accuracy + "%", 12);
		rankTxt.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankTxt.alpha = 0;
		add(rankTxt);

		anyKeyTxt = new FlxText(10, 380, 0, "PRESS ANY KEY TO CONTINUE.", 12);
		anyKeyTxt.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		anyKeyTxt.alpha = 0;
		add(anyKeyTxt);

		tweens.push(FlxTween.tween(bg, {alpha: 0.6}, 0.75, {ease: FlxEase.quadOut}));
		tweens.push(FlxTween.tween(rankTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut}));
		tweens.push(FlxTween.tween(rankSpr, {alpha: 1}, 2, {ease: FlxEase.quadOut}));
		tweens.push(FlxTween.tween(anyKeyTxt, {alpha: 1}, 2.5, {ease: FlxEase.quadOut}));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		for (i in tweens)
			if (i != null)
				i.active = true;

		if (Input.justPressed('any')) {
			FlxG.sound.playMusic(Paths.music('Basically_Professionally_Musically'), 0.75);
			ExtendableState.switchState(new SongSelectState());
		}
	}

	override function destroy() {
		for (i in tweens) {
			if (i != null) {
				i.cancel();
				i.destroy();
				i = null;
			}
		}
		tweens = FlxDestroyUtil.destroyArray(tweens);
		super.destroy();
	}
}