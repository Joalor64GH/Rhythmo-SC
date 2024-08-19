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

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var up = Input.is('up') || (gamepad != null ? Input.gamepadIs('gamepad_up') : false);
		var down = Input.is('down') || (gamepad != null ? Input.gamepadIs('gamepad_down') : false);
		var accept = Input.is('accept') || (gamepad != null ? Input.gamepadIs('gamepad_accept') : false);
		var exit = Input.is('exit') || (gamepad != null ? Input.gamepadIs('gamepad_exit') : false);

		if (up || down)
			changeSelection(up ? -1 : 1);

		if (exit) {
			FlxG.sound.play(Paths.sound("cancel"));
			close();
		}

		if (accept) {
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