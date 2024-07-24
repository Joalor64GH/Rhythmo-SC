package states;

class PlayState extends FlxState {
	override function create() {
		super.create();

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}