package;

#if desktop
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.io.Process;
#end

class Main extends openfl.display.Sprite {
	public final config:Dynamic = {
		gameDimensions: [1280, 720],
		initialState: InitialState,
		defaultFPS: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsDisplay:FPS;
	public static var toast:ToastCore;

	public function new() {
		super();

		#if windows
		WindowsAPI.darkMode(true);
		#end

		addChild(new FlxGame(config.gameDimensions[0], config.gameDimensions[1], config.initialState, config.defaultFPS, config.defaultFPS, config.skipSplash,
			config.startFullscreen));

		fpsDisplay = new FPS(10, 10, 0xffffff);
		addChild(fpsDisplay);

		#if desktop
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e:UncaughtErrorEvent) -> {
			var errMsg:String = "";
			var path:String;
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();

			dateNow = dateNow.replace(" ", "_");
			dateNow = dateNow.replace(":", "'");

			path = "./crash/" + "Rhythmo_" + dateNow + ".txt";

			for (stackItem in callStack) {
				switch (stackItem) {
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						Sys.println(stackItem);
				}
			}

			errMsg += "\nUncaught Error: "
				+ e.error
				+ "\nPlease report this error to the GitHub page: https://github.com/Joalor64GH/Rhythmo-SC\n\n> Crash Handler written by: sqirra-rng";

			try {
				if (!FileSystem.exists("./crash/"))
					FileSystem.createDirectory("./crash/");

				File.saveContent(path, errMsg + "\n");

				Sys.println(errMsg);
				Sys.println("Crash dump saved in " + Path.normalize(path));
			} catch (e:Dynamic) {
				Sys.println("Error!\nCouldn't save the crash dump because:\n" + e);
			}

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			FlxG.sound.play(Paths.sound('error'));

			Application.current.window.alert(errMsg, "Error!");
			Sys.exit(1);
		});
		#end

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);

		#if windows
		Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (evt:openfl.events.KeyboardEvent) -> {
			if (evt.keyCode == openfl.ui.Keyboard.F2) {
				var sp = Lib.current.stage;
				var position = new openfl.geom.Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

				var image:BitmapData = new BitmapData(Std.int(position.width), Std.int(position.height), false, 0xFEFEFE);
				image.draw(sp, true);

				if (!FileSystem.exists("./screenshots/"))
					FileSystem.createDirectory("./screenshots/");

				var bytes = image.encode(position, new openfl.display.PNGEncoderOptions());

				var curDate:String = Date.now().toString();

				curDate = StringTools.replace(curDate, " ", "_");
				curDate = StringTools.replace(curDate, ":", "'");

				File.saveBytes("screenshots/Screenshot-" + curDate + ".png", bytes);
			}
		});
		#end

		toast = new ToastCore();
		addChild(toast);
	}

	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	var focused:Bool = true;
	var focusMusicTween:FlxTween;

	function onWindowFocusOut() {
		focused = false;

		if (Type.getClass(FlxG.state) != PlayState) {
			oldVol = FlxG.sound.volume;
			newVol = (oldVol > 0.3) ? 0.3 : (oldVol > 0.1) ? 0.1 : 0;

			trace("Game unfocused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();
			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);

			FlxG.drawFramerate = 30;
		}
	}

	function onWindowFocusIn() {
		new FlxTimer().start(0.2, (tmr:FlxTimer) -> {
			focused = true;
		});

		if (Type.getClass(FlxG.state) != PlayState) {
			trace("Game focused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();

			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);

			FlxG.drawFramerate = config.defaultFPS;
		}
	}

	public static function updateFramerate(newFramerate:Int) {
		if (newFramerate > FlxG.updateFramerate) {
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		} else {
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}
}