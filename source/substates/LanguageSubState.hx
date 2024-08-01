package substates;

import backend.Localization.Locale;

class LanguageSubState extends ExtendableSubState {
	var langStrings:Array<Locale> = [];
	var group:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;

	public function new() {
		super();

		var initLangString = Paths.getText(Paths.file('languages/languagesData.txt'));

		if (Assets.exists(Paths.file('languages/languagesData.txt'))) {
			initLangString = Assets.getText(Paths.file('languages/languagesData.txt')).trim().split('\n');

			for (i in 0...initLangString.length)
				initLangString[i] = initLangString[i].trim();
		}

		for (i in 0...initLangString.length) {
			var data:Array<String> = initLangString[i].split(':');
			langStrings.push(new Locale(data[0], data[1]));
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

		var title:FlxText = new FlxText(0, 0, 0, 'SELECT A LANGUAGE', 12);
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

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.is('up') || Input.is('down'))
			changeSelection(Input.is('up') ? -1 : 1);

		if (Input.is('exit')) {
			FlxG.sound.play(Paths.sound("cancel"));
			close();
		}

		if (Input.is('accept')) {
			SaveData.settings.lang = langStrings[curSelected].code;
			Localization.switchLanguage(SaveData.settings.lang);
			SaveData.saveSettings();
			ExtendableState.resetState();
		}
	}

	private function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, langStrings.length - 1);
		group.forEach(function(txt:FlxText) {
			txt.color = (txt.ID == curSelected) ? FlxColor.LIME : FlxColor.WHITE;
		});
	}
}