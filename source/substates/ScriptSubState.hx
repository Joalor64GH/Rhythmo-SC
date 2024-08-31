package substates;

class ScriptSubState extends ExtendableSubState {
	var daScript:Hscript;

	public function new(path:String, ?args:Array<Dynamic>) {
		daScript = new Hscript(Paths.script('classes/$path'));
		daScript.setVariable('this', this);
		daScript.setVariable('add', function(Object:FlxBasic) {
			add(Object);
		});
		daScript.setVariable('remove', function(Object:FlxBasic) {
			remove(Object);
		});
		daScript.setVariable('insert', function(position:Int, object:FlxBasic) {
			insert(position, object);
		});

		super();
	}

	public override function create() {
		daScript.executeFunc("create", []);
		super.create();
	}

	public override function beatHit() {
		daScript.executeFunc("beatHit", [curBeat]);
		super.beatHit();
	}

	public override function stepHit() {
		daScript.executeFunc("stepHit", [curStep]);
		super.stepHit();
	}

	public override function update(elapsed:Float) {
		daScript.executeFunc("update", [elapsed]);
		super.update(elapsed);
	}

	public override function destroy() {
		daScript.executeFunc("destroy", []);
		super.destroy();
	}
}