package;

#if desktop
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.io.Process;
import backend.ALSoftConfig;
#end
import debug.FPS;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
class Main extends openfl.display.Sprite {
	public final config:Dynamic = {
		gameDimensions: [1280, 720],
		initialState: InitialState,
		defaultFPS: SaveData.settings.framerate,
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
			var stack:Array<String> = [];
			stack.push(e.error);

			for (stackItem in CallStack.exceptionStack(true)) {
				switch (stackItem) {
					case CFunction:
						stack.push('C Function');
					case Module(m):
						stack.push('Module ($m)');
					case FilePos(s, file, line, column):
						stack.push('$file (line $line)');
					case Method(classname, method):
						stack.push('$classname (method $method)');
					case LocalFunction(name):
						stack.push('Local Function ($name)');
				}
			}

			e.preventDefault();
			e.stopPropagation();
			e.stopImmediatePropagation();

			final msg:String = stack.join('\n');

			#if sys
			try {
				if (!FileSystem.exists('./crash/'))
					FileSystem.createDirectory('./crash/');

				File.saveContent('./crash/'
					+ Lib.application.meta.get('file')
					+ '-'
					+ Date.now().toString().replace(' ', '-').replace(':', "'")
					+ '.txt',
					msg
					+ '\n');
			} catch (e:Dynamic) {
				Sys.println("Error!\nCouldn't save the crash dump because:\n" + e);
			}
			#end

			FlxG.bitmap.dumpCache();
			FlxG.bitmap.clearCache();

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			FlxG.sound.play(Paths.sound('error'));

			#if windows
			WindowsAPI.messageBox('Error!',
				'Uncaught Error: \n: ' + msg + '\n\nIf you think this shouldn\'t have happened, report this error to GitHub repository!\nhttps://github.com/Joalor64GH/Rhythmo-SC/issues',
				MSG_ERROR);
			#else
			Lib.application.window.alert('Uncaught Error: \n'
				+ msg
				+ '\n\nIf you think this shouldn\'t have happened, report this error to GitHub repository!\nhttps://github.com/Joalor64GH/Rhythmo-SC/issues',
				'Error!');
			#end
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

				File.saveBytes("screenshots/Screenshot-" + curDate + ".png", bytes);
			}
		});
		#end

		FlxG.mouse.visible = false;

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