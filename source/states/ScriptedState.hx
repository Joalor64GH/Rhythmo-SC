package states;

class ScriptedState extends ExtendableState {
	public var path:String = "";
	public var script:Hscript = null;

	public static var instance:ScriptedState = null;

	public function new(_path:String = null, ?args:Array<Dynamic>) {
		if (_path != null)
			path = _path;

		instance = this;

		try {
			var folders:Array<String> = [Paths.file('classes/')];
			#if FUTURE_POLYMOD
			for (mod in ModHandler.getModIDs())
				folders.push('mods/' + mod + '/classes/');
			#end

			for (folder in folders) {
				if (FileSystem.exists(folder)) {
					for (file in FileSystem.readDirectory(folder)) {
						for (scriptExt in Paths.HSCRIPT_EXT) {
							if (file.startsWith(path) && file.endsWith(scriptExt)) {
								path = folder + file;
							}
						}
					}
				}
			}

			script = new Hscript(path, false);
			script.execute(path, false);

			scriptSet('this', this);
			scriptSet('add', add);
			scriptSet('remove', remove);
			scriptSet('multiAdd', multiAdd);
			scriptSet('multiRemove', multiRemove);
			scriptSet('insert', insert);
			scriptSet('openSubState', openSubState);
		} catch (e:Dynamic) {
			script = null;
			trace('Error while getting script: $path!\n$e');
		}

		scriptExecute('new', args);

		super();
	}

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		scriptExecute('create', []);
		super.create();
	}

	override function update(elapsed:Float) {
		scriptExecute('update', [elapsed]);
		super.update(elapsed);

		if (Input.justPressed('f4')) // emergency exit
			ExtendableState.switchState(new MenuState());
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
		script?.setVariable(key, value);
	}

	function scriptExecute(func:String, args:Array<Dynamic>) {
		try {
			script?.executeFunc(func, args);
		} catch (e:Dynamic) {
			trace('Error executing $func!\n$e');
		}
	}
}