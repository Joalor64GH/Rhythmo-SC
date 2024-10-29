package states;

class ScriptedState extends ExtendableState {
	public var path:String = "";
	public var script:Hscript = null;

	public static var instance:ScriptedState = null;

	public function new(_path:String = null) {
		if (_path != null)
			path = _path;
		super();
	}

	override function create() {
		instance = this;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		try {
			var folders:Array<String> = [Paths.file('classes/')];
			#if FUTURE_POLYMOD
			for (mod in ModHandler.getMods())
				folders.push('mods/' + mod + '/classes/');
			#end
			for (folder in folders) {
				if (FileSystem.exists(folder)) {
					for (file in FileSystem.readDirectory(folder)) {
						if (file.endsWith('.hxs')) {
							path = folder + file;
						}
					}
				}
			}
			
			script = new Hscript(path, false);
			script.execute(path, false);

			scriptSet('this', this);
			scriptSet('add', add);
			scriptSet('remove', remove);
			scriptSet('insert', insert);
			scriptSet('openSubState', openSubState);
		} catch (e:Dynamic) {
			script = null;
			trace('Error while getting script!\n$e');
			switchState(new MenuState());
		}

		scriptExecute('create', []);

		super.create();
	}

	override function update(elapsed:Float) {
		scriptExecute('update', [elapsed]);
		super.update(elapsed);

		if (Input.justPressed('f4')) // emergency exit
			switchState(new MenuState());
	}

	override function beatHit() {
		scriptExecute('beatHit', [curBeat]);
		scriptSet('curBeat', curBeat);
		super.beatHit();
	}

	override function stepHit() {
		scriptExecute('stepHit', [curStep]);
		scriptSet('curStep', curStep);
		super.stepHit();
	}

	override function destroy() {
		scriptExecute('destroy', []);
		super.destroy();
	}

	override function openSubState(SubState:FlxSubState):Void {
		scriptExecute('openSubState', []);
		super.openSubState(SubState);
	}

	override function closeSubState():Void {
		scriptExecute('closeSubState', []);
		super.closeSubState();
	}

	function scriptSet(key:String, value:Dynamic) {
		if (script != null)
			script.setVariable(key, value);
	}

	function scriptExecute(func:String, args:Array<Dynamic>) {
		if (script != null) {
			try {
				script.executeFunc(func, args);
			} catch (e:Dynamic) {
				trace('Error executing $func!\n$e');
			}
		}
	}
}