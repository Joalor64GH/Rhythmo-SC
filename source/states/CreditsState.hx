package states;

typedef CreditsPrefDef = {
	var ?menuBG:String;
	var ?menuBGColor:Array<Int>;
	var ?tweenColor:Bool;
	var users:Array<CreditsUserDef>;
}

typedef CreditsUserDef = {
	var name:String;
	var iconData:Array<Dynamic>; // icon name, x offset, y offset
	var textData:Array<String>; // description, quote
	var colors:Array<Int>;
	var urlData:Array<Array<String>>; // social name, link
	var ?sectionName:String;
}

class CreditsState extends ExtendableState {
	var credData:CreditsPrefDef;
	var credsGrp:FlxTypedGroup<FlxText>;

	var curSelected:Int = -1;
	var curSocial:Int = -1;

	var menuBG:FlxSprite;
	var menuColorTween:FlxTween;

	var iconArray:Array<CreditsIcon> = [];

	var topBar:FlxSprite;
	var topMarker:FlxText;
	var rightMarker:FlxText;
	var bottomMarker:FlxText;
	var centerMarker:FlxText;

	var camFollow:FlxObject;

	override function create() {
		super.create();

		credData = Json.parse(Paths.getTextFromFile('credits.json'));

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);

		if (credData.menuBG != null && credData.menuBG.length > 0)
			menuBG = new FlxSprite().loadGraphic(Paths.image(credData.menuBG));
		else
			menuBG = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/credits_bg'));
		menuBG.screenCenter();
		menuBG.scrollFactor.set();
		add(menuBG);

		var finalColor:FlxColor = FlxColor.fromRGB(credData.menuBGColor[0], credData.menuBGColor[1], credData.menuBGColor[2]);
		if (!credData.tweenColor)
			menuBG.color = finalColor;

		credsGrp = new FlxTypedGroup<FlxText>();
		add(credsGrp);

		for (i in 0...credData.users.length) {
			var name:FlxText = new FlxText(20, 60 + (i * 60), 0, credData.users[i].name, 32);
            name.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			name.ID = i;
			credsGrp.add(name);

			var icon:CreditsIcon = new CreditsIcon((name.width + credData.users[i].iconData[1]), credData.users[i].iconData[2], credData.users[i].iconData[0]);
			if (credData.users[i].iconData[3] != null)
				icon.setGraphicSize(Std.int(icon.width * credData.users[i].iconData[3]));
			if (credData.users[i].iconData.length <= 1 || credData.users[i].iconData == null)
				icon.visible = false;
			icon.sprTracker = name;
			iconArray.push(icon);
			add(icon);

			if (curSelected == -1)
				curSelected = i;
		}

		if (curSocial == -1)
			curSocial = 0;

		topBar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		topBar.setGraphicSize(FlxG.width, 48);
		topBar.updateHitbox();
		topBar.scrollFactor.set();
		topBar.screenCenter(X);
		add(topBar);
		topBar.y -= topBar.height;

		topMarker = new FlxText(8, 8, 0, "CREDITS").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		topMarker.scrollFactor.set();
		topMarker.alpha = 0;
		add(topMarker);

		centerMarker = new FlxText(0, 8, FlxG.width, "< PLATFORM >").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		centerMarker.alignment = CENTER;
		centerMarker.screenCenter(X);
		centerMarker.scrollFactor.set();
		centerMarker.alpha = 0;
		add(centerMarker);

		rightMarker = new FlxText(-8, 8, FlxG.width, "RHYTHMO").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		rightMarker.scrollFactor.set();
		rightMarker.alignment = RIGHT;
		rightMarker.alpha = 0;
		add(rightMarker);

		bottomMarker = new FlxText(0, FlxG.height - 24, 0, "", 32);
		bottomMarker.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		bottomMarker.textField.background = true;
		bottomMarker.textField.backgroundColor = FlxColor.BLACK;
		bottomMarker.scrollFactor.set();
		add(bottomMarker);

		FlxTween.tween(topMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(centerMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(rightMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});

		changeSelection();
		updateSocial();

		FlxG.camera.follow(camFollow, LOCKON, 0.25);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		topBar.y = FlxMath.lerp(topBar.y, 0, elapsed * 6);

		topMarker.y = topBar.y + 5;
		centerMarker.y = topBar.y + 5;
		rightMarker.y = topBar.y + 5;

		var controlArray:Array<Bool> = [FlxG.keys.justPressed.UP, FlxG.keys.justPressed.DOWN, Input.is('up'), Input.is('down'), FlxG.mouse.wheel == 1, FlxG.mouse.wheel == -1];
		if (controlArray.contains(true)) {
			for (i in 0...controlArray.length) {
				if (controlArray[i] == true) {
					if (i > 1) {
						if (i == 2 || i == 4)
							curSelected--;
						else if (i == 3 || i == 5)
							curSelected++;
						FlxG.sound.play(Paths.sound('scroll'));
					}
					if (curSelected < 0)
						curSelected = credData.users.length - 1;
					if (curSelected >= credData.users.length)
						curSelected = 0;
					changeSelection();
				}
			}
		}

		if (Input.is('left') || Input.is('right')) {
			FlxG.sound.play(Paths.sound('scroll'));
			updateSocial(Input.is('left') ? -1 : 1);
		}

		if (Input.is('accept') && credData.users[curSelected].urlData[curSocial][1] != null) {
            #if linux
            Sys.command('/usr/bin/xdg-open', [credData.users[curSelected].urlData[curSocial][1]]);
            #else
            FlxG.openURL(credData.users[curSelected].urlData[curSocial][1]);
            #end
        }

		if (Input.is('exit')) {
			FlxG.sound.play(Paths.sound('cancel'));
			ExtendableState.switchState(new MenuState());
		}
	}

	function changeSelection(change:Int = 0) {
		credsGrp.forEach(function(txt:FlxText) {
			txt.alpha = (txt.ID == curSelected) ? 1 : 0.6;
			camFollow.y = txt.y;
		});

		updateSectionName();

		if (credData.tweenColor) {
			var color:FlxColor = FlxColor.fromRGB(credData.users[curSelected].colors[0], credData.users[curSelected].colors[1],
				credData.users[curSelected].colors[2]);

			if (menuColorTween != null)
				menuColorTween.cancel();

			if (color != menuBG.color) {
				menuColorTween = FlxTween.color(menuBG, 0.35, menuBG.color, color, {
					onComplete: (tween:FlxTween) -> {
						menuColorTween = null;
					}
				});
			}
		}

		updateBottomMarker();

		curSocial = 0;
		updateSocial();
	}

	function updateSectionName() {
		var sectionName = credData.users[curSelected].sectionName;
		var altSectionName = '';
		try {
			for (i in 0...curSelected) {
				var hisAlt = credData.users[curSelected - (i + 1)].sectionName;
				if (hisAlt != null && hisAlt.length >= 1) {
					altSectionName = hisAlt;
					break;
				}
			}
		} catch (e) {}

		rightMarker.text = sectionName ?? altSectionName;
	}

	function updateSocial(huh:Int = 0) {
		if (credData.users[curSelected].urlData[curSocial][0] == null)
			return;

		curSocial += huh;
		if (curSocial < 0)
			curSocial = credData.users[curSelected].urlData.length - 1;
		if (curSocial >= credData.users[curSelected].urlData.length)
			curSocial = 0;

		if (credData.users[curSelected].urlData[curSocial][0] != null) {
			var textValue = '< ' + credData.users[curSelected].urlData[curSocial][0] + ' >';
			if (credData.users[curSelected].urlData[curSocial][0] == null)
				textValue = "";
			centerMarker.text = textValue;
		}
	}

	function updateBottomMarker() {
		var textData = credData.users[curSelected].textData;
		var fullText:String = '';

		if (textData[0] != null && textData[0].length >= 1)
			fullText += textData[0];

		if (textData[1] != null && textData[1].length >= 1)
			fullText += ' - "' + textData[1] + '"';

		bottomMarker.text = fullText;
		bottomMarker.screenCenter(X);
	}
}

class CreditsIcon extends GameSprite {
	public var sprTracker:FlxSprite;
	public var icon:String = '';

	public function new(x:Float = 0, y:Float = 0, icon:String = '') {
		super(x, y);

		this.icon = icon;

		try {
			loadGraphic(Paths.image('credits/$icon'));
		} catch(e:Dynamic) {
			trace('error getting icon: $e');
			loadGraphic(Paths.image('credits/placeholder'));
		}
		setGraphicSize(65, 70);
		scrollFactor.set();
		updateHitbox();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y);
	}
}