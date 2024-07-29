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

	public function new() {
		super();

		addChild(new FlxGame(config.gameDimensions[0], config.gameDimensions[1], config.initialState, config.defaultFPS, config.defaultFPS, config.skipSplash,
			config.startFullscreen));

		fpsDisplay = new FPS(10, 10, 0xFFFFFF);
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
			} catch(e:Dynamic) {
				Sys.println("Error!\nCouldn't save the crash dump because:\n" + e)
			}

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			FlxG.sound.play(Paths.sound('error'));

			Application.current.window.alert(errMsg, "Error!");
			Sys.exit(1);
		});
		#end
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