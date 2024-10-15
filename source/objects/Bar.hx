package objects;

import openfl.geom.*;

class Bar extends GameSprite {
	private var _bgBarBit:BitmapData;
	private var _bgBarRect:Rectangle;
	private var _zeroOffset:Point;

	private var _fgBarBit:BitmapData;
	private var _fgBarRect:Rectangle;
	private var _fgBarPoint:Point;

	private var barWidth(default, null):Int;
	private var barHeight(default, null):Int;

	public var value:Float = 0;

	public function new(x:Float = 0, y:Float = 0, width:Int = 100, height:Int = 10, bgColor:FlxColor, fgColor:FlxColor) {
		super(x, y);

		this.barWidth = width;
		this.barHeight = height;

		_bgBarRect = new Rectangle();
		_zeroOffset = new Point();

		_fgBarRect = new Rectangle();
		_fgBarPoint = new Point();

		_bgBarBit = Paths.setBitmap("bgBarBitmap", new BitmapData(barWidth, barHeight, true, bgColor));
		_bgBarRect.setTo(0, 0, barWidth, barHeight);

		_fgBarBit = Paths.setBitmap("fgBarBitmap", new BitmapData(barWidth, barHeight, true, fgColor));
		_fgBarRect.setTo(0, 0, barWidth, barHeight);

		makeGraphic(width, height, FlxColor.TRANSPARENT, true);
	}

	override public function destroy() {
		_bgBarBit = null;
		Paths.disposeBitmap("bgBarBitmap");
		_bgBarRect = null;
		_zeroOffset = null;

		_fgBarBit = null;
		Paths.disposeBitmap("fgBarBitmap");
		_fgBarRect = null;
		_fgBarRect = null;

		super.destroy();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		pixels.copyPixels(_bgBarBit, _bgBarRect, _zeroOffset);

		_fgBarRect.width = (value * barWidth);
		_fgBarRect.height = barHeight;

		pixels.copyPixels(_fgBarBit, _fgBarRect, _fgBarPoint, null, null, true);
	}
}