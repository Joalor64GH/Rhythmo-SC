package objects;

class Note extends GameSprite {
	public var dir:String = ''; // note direction
	public var type:String = ''; // receptor or plain note

	public var shouldHit:Bool = true;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	public var lastNote:Note;
	public var rawNoteData:Int = 0;

	public var strum:Float = 0.0;

	public var colorSwap:ColorSwap;

	public function new(x:Float, y:Float, dir:String, type:String) {
		super(x, y);

		this.dir = dir;
		this.type = type;

		loadGraphic(Paths.image('gameplay/note_$dir'), true, 200, 200);
		scale.set(0.6, 0.6);

		animation.add("note", [0], 1);
		animation.add("press", [1], 1);
		animation.add("receptor", [2], 1);

		animation.play((type == 'receptor') ? "receptor" : "note");

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		var noteColor = NoteColors.getNoteColor(Utilities.getNoteIndex(dir));

		if (colorSwap != null && noteColor != null) {
			colorSwap.r = noteColor[0];
			colorSwap.g = noteColor[1];
			colorSwap.b = noteColor[2];
		}
	}

	public function press() {
		animation.play("press");

		scale.set(0.5, 0.5);
		FlxTween.cancelTweensOf(this.scale);
		FlxTween.tween(this.scale, {x: 0.6, y: 0.6}, 0.3, {ease: FlxEase.quadOut});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (type != 'receptor') {
			calculateCanBeHit();
			
			if (tooLate)
				if (alpha > 0.3)
					alpha = 0.3;
		}
	}

	public function calculateCanBeHit() {
		if (this != null) {
			if (shouldHit) {
				if (strum > Conductor.songPosition - Conductor.safeZoneOffset && strum < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			} else {
				if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
					&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strum < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
	}
}