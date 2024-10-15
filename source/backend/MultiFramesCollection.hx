package;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;

class MultiFramesCollection extends FlxFramesCollection {
	public var parentedFrames:Array<FlxFramesCollection> = [];

	public function new(parent:FlxGraphic, ?border:FlxPoint) {
		super(parent, USER("MULTI"), border);
	}

	public static function findFrame(graphic:FlxGraphic, ?border:FlxPoint):MultiFramesCollection {
		if (border == null)
			border = FlxPoint.weak();

		var atlasFrames:Array<MultiFramesCollection> = cast graphic.getFramesCollections(USER("MULTI"));

		for (atlas in atlasFrames)
			if (atlas.border.equals(border))
				return atlas;

		return null;
	}

	public function addFrames(collection:FlxFramesCollection) {
		if (collection == null || collection.frames == null)
			return;

		collection.parent.incrementUseCount();
		parentedFrames.push(collection);

		for (f in collection.frames) {
			if (f != null) {
				pushFrame(f);
				f.parent = collection.parent;
			}
		}
	}

	public override function destroy():Void {
		if (parentedFrames != null) {
			for (collection in parentedFrames) {
				if (collection != null)
					collection.parent.decrementUseCount();
			}
			parentedFrames = null;
		}
		super.destroy();
	}
}