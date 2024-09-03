package states;

import flixel.addons.transition.FlxTransitionableState;

class ModsState extends ExtendableState {
	var daMods:FlxTypedGroup<FlxText>;
	var iconArray:Array<ModIcon> = [];
	var description:FlxText;
	var curSelected:Int = 0;

	var camFollow:FlxObject;

	override function create() {
		super.create();

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/mods_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		daMods = new FlxTypedGroup<FlxText>();
		add(daMods);

		for (i in 0...ModHandler.trackedMods.length) {
			var text:FlxText = new FlxText(20, 60 + (i * 60), ModHandler.trackedMods[i].title, 32);
			text.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.ID = i;
			daMods.add(text);

			var icon:ModIcon = new ModIcon(ModHandler.trackedMods[i].icon);
			icon.sprTracker = text;
			iconArray.push(icon);
			add(icon);
		}

		description = new FlxText(0, FlxG.height * 0.1, FlxG.width * 0.9, '', 28);
		description.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.scrollFactor.set();
		add(description);

		changeSelection();

		FlxG.camera.follow(camFollow, LOCKON, 0.25);
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
			FlxG.sound.play(Paths.sound('cancel'));
			ModHandler.reload();
			FlxTransitionableState.skipNextTransIn = true;
           	FlxTransitionableState.skipNextTransOut = true;
			ExtendableState.switchState(new MenuState());
		} else if (accept) {
			if (!FlxG.save.data.disabledMods.contains(ModHandler.trackedMods[curSelected].id)) {
				FlxG.save.data.disabledMods.push(ModHandler.trackedMods[curSelected].id);
				FlxG.save.flush();
				changeSelection();
			} else {
				FlxG.save.data.disabledMods.remove(ModHandler.trackedMods[curSelected].id);
				FlxG.save.flush();
				changeSelection();
			}
		}
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, ModHandler.trackedMods.length - 1);

		for (i in 0...iconArray.length)
			iconArray[i].alpha = (!FlxG.save.data.disabledMods.contains(ModHandler.trackedMods[i].id)) ? 1 : 0.6;

		daMods.forEach(function(txt:FlxText) {
			txt.alpha = (!FlxG.save.data.disabledMods.contains(ModHandler.trackedMods[txt.ID].id)) ? 1 : 0.6;
			if (txt.ID == curSelected)
				camFollow.y = txt.y;
		});

		if (ModHandler.trackedMods[curSelected].description != null) {
			description.text = ModHandler.trackedMods[curSelected].description;
			description.screenCenter(X);
		}
	}
}

class ModIcon extends GameSprite {
	public var sprTracker:FlxSprite;

	public function new(bytes:haxe.io.Bytes) {
		super();

		if (bytes != null && bytes.length > 0) {
			try {
				loadGraphic(BitmapData.fromBytes(bytes));
			} catch (e:Dynamic) {
				FlxG.log.error(e);
				loadGraphic(Paths.image('menu/unknownMod'));
			}
		} else
			loadGraphic(Paths.image('menu/unknownMod'));

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