package states;

class ScriptedState extends ExtendableState {
	public var script:Hscript;

	public function new(path:String, ?args:Array<Dynamic>) {
		super();

		script = new Hscript(Paths.script('classes/$path'));

		script.setVariable('state', this);
		script.setVariable('add', function(obj:FlxBasic) {
			add(obj);
		});
		script.setVariable('remove', function(obj:FlxBasic) {
			remove(obj);
		});
		script.setVariable('insert', function(pos:Int, obj:FlxBasic) {
			insert(pos, obj);
		});

		script.executeFunc('new', (args != null) ? args : []);
	}

	override function draw() {
		super.draw();
		script.executeFunc('draw', []);
	}

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		script.executeFunc('update', [elapsed]);
	}

	override function beatHit() {
		super.beatHit();
		script.executeFunc('beatHit', [curBeat]);
	}

	override function stepHit() {
		super.stepHit();
		script.executeFunc('stepHit', [curStep]);
	}

	override function destroy() {
		super.destroy();
		script.executeFunc('destroy', []);
	}
}