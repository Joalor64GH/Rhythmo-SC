package states;

class PlayState extends FlxState {
	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];
	var strumline:FlxTypedGroup<Note>;

	var scoreTxt:FlxText;

	override function create() {
		super.create();

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(i * 150, 50, noteDirs[i], "receptor");
			strumline.add(note);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

        if (Input.is("exit"))
            FlxG.switchState(MenuState.new);
	}
}