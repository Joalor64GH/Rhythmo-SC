package states;

class ScriptedState extends ExtendableState {
	public var script:Hscript;
	public static var instance:ScriptedState = null;

	public function new(path:String) {
		super();

		instance = this;

		try {
			script = new Hscript(Paths.script('classes/$path'));
		} catch (e:Dynamic) {
			trace('Error while getting script!\n$e');
			ExtendableState.switchState(new TitleState());
		}

		scriptSet('state', instance);
		scriptSet('add', add);
		scriptSet('remove', remove);
		scriptSet('kill', kill);
		scriptSet('openSubState', openSubState);
	}

	override function draw() {
		scriptExecute('draw', []);
		super.draw();
	}

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
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
		if (script != null)
			script.executeFunc(func, args);
	}
}