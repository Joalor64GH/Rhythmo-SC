package backend;

class Utilities {
	public static inline function fpsLerp(v1:Float, v2:Float, ratio:Float):Float {
		return FlxMath.lerp(v1, v2, getFPSRatio(ratio));
	}

	public static inline function getFPSRatio(ratio:Float):Float {
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
	}

	public static inline function maxInt(p1:Int, p2:Int)
		return p1 < p2 ? p2 : p1;

	public static inline function getDefault<T>(v:Null<T>, defaultValue:T):T {
		return (v == null || isNaN(v)) ? defaultValue : v;
	}

	public static inline function isNaN(v:Dynamic) {
		if (v is Float || v is Int)
			return Math.isNaN(cast(v, Float));
		return false;
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));
}