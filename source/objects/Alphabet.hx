package objects;

class Alphabet extends FlxSpriteGroup {
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;
	public var textSize:Float = 1.0;

	public var text:String = "";

	var _finalText:String = "";
	var yMulti:Float = 1;

	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public var lettersArray:Array<AlphaCharacter> = [];

	public var finishedText:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, ?textSize:Float = 1) {
		super(x, y);
		forceX = Math.NEGATIVE_INFINITY;
		this.textSize = textSize;

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "") {
			addText();
		} else {
			finishedText = true;
		}
	}

	public function changeText(newText:String) {
		for (i in 0...lettersArray.length) {
			var letter = lettersArray[0];
			remove(letter);
			lettersArray.remove(letter);
		}
		lettersArray = [];
		splitWords = [];
		loopNum = 0;
		xPos = 0;
		curRow = 0;
		consecutiveSpaces = 0;
		xPosResetted = false;
		finishedText = false;
		lastSprite = null;

		var lastX = x;
		x = 0;
		_finalText = newText;
		text = newText;

		if (text != "") {
			addText();
		} else {
			finishedText = true;
		}
		x = lastX;
	}

	public function addText() {
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords) {
			var spaceChar:Bool = (character == " " || character == "_");
			if (spaceChar) {
				consecutiveSpaces++;
			}

			if (true) {
				if (lastSprite != null) {
					xPos = lastSprite.x + lastSprite.width;
				}

				if (consecutiveSpaces > 0) {
					xPos += 40 * consecutiveSpaces * textSize;
				}
				consecutiveSpaces = 0;

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0, textSize, character, isBold);
				add(letter);

				lettersArray.push(letter);
				lastSprite = letter;
			}
		}
	}

	function doSplitWords():Void {
		splitWords = _finalText.split("");
	}

	var loopNum:Int = 0;
	var xPos:Float = 0;

	public var curRow:Int = 0;

	var consecutiveSpaces:Int = 0;

	override function set_color(color:FlxColor) {
		for (i in members) {
			i.color = color;
		}

		return this.color = color;
	}

	override function update(elapsed:Float) {
		if (isMenuItem) {
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
			if (forceX != Math.NEGATIVE_INFINITY) {
				x = forceX;
			} else {
				x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
			}
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxText {
	private var textSize:Float = 1;

	public function new(x:Float, y:Float, textSize:Float, text:String, bold:Bool) {
		super();
		setFormat(Paths.font("vcr.ttf"), Std.int(96 * textSize), bold ? FlxColor.WHITE : FlxColor.BLACK, LEFT, OUTLINE, FlxColor.BLACK);
		if (bold)
			borderSize = 2;
		this.textSize = textSize;
		this.text = text;
		setPosition(x, y);
		antialiasing = false;
	}
}