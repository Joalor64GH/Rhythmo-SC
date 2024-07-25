package states;

class PlayState extends ExtendableState {
	public static var instance:PlayState;
	public static var songMultiplier:Float = 1;

	public var song:SongData;
	
	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];
	var strumline:FlxTypedGroup<Note>;
	var notes:FlxTypedGroup<Note>;

	var spawnNotes:Array<Note> = [];

	var ratings:FlxTypedGroup<Rating>;

	var score:Int = 0;
	var scoreTxt:FlxText;
	var timeBar:Bar;

	override public function new() {
		super();

		if (song == null) {
			song = {
				song: "Test",
				notes: [],
				bpm: 100,
				timeSignature: [4, 4]
			};
		}

		instance = this;
	}

	override function create() {
		super.create();

		Conductor.changeBPM(song.bpm);

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		var noteWidth:Float = 200 * 0.6;
		var totalWidth:Float = (noteDirs.length - 1) * noteWidth;
		var startX:Float = (FlxG.width - totalWidth) / 2;

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(startX + i * noteWidth, 50, noteDirs[i], "receptor");
			strumline.add(note);
		}

		timeBar = new Bar(0, 0, FlxG.width, 10, FlxColor.WHITE, FlxColor.fromRGB(30, 144, 255));
		timeBar.screenCenter(X);
		timeBar.y = FlxG.height + 10;
		add(timeBar);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.is("exit"))
			FlxG.switchState(MenuState.new);

		strumline.forEach((spr:Note) -> {
			switch (spr.dir) {
				case "left":
					if (Input.is("left", PRESSED)) spr.press(); else spr.animation.play("receptor");
				case "down":
					if (Input.is("down", PRESSED)) spr.press(); else spr.animation.play("receptor");
				case "up":
					if (Input.is("up", PRESSED)) spr.press(); else spr.animation.play("receptor");
				case "right":
					if (Input.is("right", PRESSED)) spr.press(); else spr.animation.play("receptor");
			}
		});
	}
}