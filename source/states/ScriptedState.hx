package states;

class ScriptedState extends ExtendableState {
	public var script:Hscript;
	public static var instance:ScriptedState = null;

	public function new(path:String, ?args:Array<Dynamic>) {
		super();

		try {
			script = new Hscript(Paths.script('classes/$path'));
		} catch (e:Dynamic) {
			trace('Error while getting script!\n$e');
			ExtendableState.switchState(new TitleState());
		}

		scriptExecute('new', (args != null) ? args : []);

		instance = this;
	}

	override function draw() {
		super.draw();
		scriptExecute('draw', []);
	}

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		scriptExecute('update', [elapsed]);
	}

	override function beatHit() {
		super.beatHit();
		scriptExecute('beatHit', [curBeat]);
	}

	override function stepHit() {
		super.stepHit();
		scriptExecute('stepHit', [curStep]);
	}

	override function destroy() {
		super.destroy();
		scriptExecute('destroy', []);
	}

	function scriptExecute(func:String, args:Array<Dynamic>) {
		if (script != null)
			script.executeFunc(func, args);
	}
}