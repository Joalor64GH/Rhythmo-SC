package options;

import backend.Localization.Locale;

class LanguageState extends ExtendableState {
	var langStrings:Array<Locale> = [];
	var group:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;

	override function create() {
		super.create();

		var initLangString = Paths.getText(Paths.txt('languages/languagesData'));

		if (Assets.exists(Paths.txt('languages/languagesData'))) {
			initLangString = Assets.getText(Paths.txt('languages/languagesData')).trim().split('\n');

			for (i in 0...initLangString.length)
				initLangString[i] = initLangString[i].trim();
		}

		for (i in 0...initLangString.length) {
			var data:Array<String> = initLangString[i].split(':');
			langStrings.push(new Locale(data[0], data[1]));
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		var title:FlxText = new FlxText(0, 0, 0, Localization.get("langSelect", SaveData.settings.lang), 12);
		title.setFormat(Paths.font('vcr.ttf'), 70, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.screenCenter(X);
		add(title);

		group = new FlxTypedGroup<FlxText>();
		add(group);

		for (i in 0...langStrings.length) {
			var text:FlxText = new FlxText(0, 300 + (i * 70), 0, langStrings[i].lang, 32);
			text.setFormat(Paths.font('vcr.ttf'), 80, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.screenCenter(X);
			text.ID = i;
			group.add(text);
		}

		var noticeTxt:FlxText = new FlxText(5, FlxG.height - 24, 0, Localization.get("langNotCompletelyAccurate", SaveData.settings.lang), 12);
		noticeTxt.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noticeTxt.screenCenter(X);
		add(noticeTxt);

		changeSelection(0, false);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		if (Input.justPressed('exit')) {
			FlxG.sound.play(Paths.sound("cancel"));
			ExtendableState.switchState(new OptionsState());
		}

		if (Input.justPressed('accept')) {
			SaveData.settings.lang = langStrings[curSelected].code;
			Localization.switchLanguage(SaveData.settings.lang);
			SaveData.saveSettings();
			ExtendableState.switchState(new OptionsState());
		}
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, langStrings.length - 1);
		group.forEach(function(txt:FlxText) {
			txt.color = (txt.ID == curSelected) ? FlxColor.LIME : FlxColor.WHITE;
		});
	}
}