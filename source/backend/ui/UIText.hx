package backend.ui;

import backend.FlxTextExt;

class UIText extends FlxTextExt {
	public var optimized:Bool = false;

	public function new(x, y, w, text, size:Int = 15, color:FlxColor = 0xFFFFFFFF, ?outline:Bool = true) {
		super(x, y, w, text, size, false);
		this.color = color;

		if (outline) {
			this.borderStyle = OUTLINE_FAST;
			this.borderColor = 0x88000000;
			this.borderSize = 1;
		}
		this.active = false;
		this.antialiasing = false;
	}

	public override function applyBorderStyle() {
		if (borderStyle == OUTLINE_FAST && optimized) {
			var iterations:Int = Std.int(borderSize * borderQuality);
			if (iterations <= 0)
				iterations = 1;
			var delta:Float = borderSize / iterations;

			applyFormats(_formatAdjusted, true);

			var curDelta:Float = delta;
			for (i in 0...iterations) {
				copyTextWithOffset(-curDelta, -curDelta);
				copyTextWithOffset(curDelta * 2, curDelta * 2);

				_matrix.translate(-curDelta, -curDelta);
				curDelta += delta;
			}
			return;
		}
		super.applyBorderStyle();
	}
}