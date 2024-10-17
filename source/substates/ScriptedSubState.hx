package substates;

class ScriptedSubState extends ExtendableSubState {
	public var path:String = "";
	public var script:Hscript = null;
	public static var instance:ScriptedSubState = null;

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
			if (FileSystem.exists(Paths.script('classes/$path')))
				path = Paths.script('classes/$path');
			script = new Hscript(path, false);
			script.execute(path, false);

			scriptSet('this', this);
			scriptSet('add', add);
			scriptSet('remove', remove);
			scriptSet('insert', insert);
		} catch (e:Dynamic) {
			script = null;
			trace('Error while getting script!\n$e');
			ExtendableState.switchState(new TitleState());
		}

		scriptExecute('create', []);

		super.create();
	}

	override function update(elapsed:Float) {
		scriptExecute('update', [elapsed]);
		super.update(elapsed);
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

	function scriptSet(key:String, value:Dynamic) {
		if (script != null)
			script.setVariable(key, value);
	}

	function scriptExecute(func:String, args:Array<Dynamic>) {
		if (script != null)
			script.executeFunc(func, args);
	}
}