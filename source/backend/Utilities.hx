package backend;

@:keep
class Utilities {
	public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	public static function truncateFloat(number:Float, precision:Int):Float {
		if (precision < 1)
			return Math.ffloor(number);

		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function getDirection(index:Int):String {
		return switch (index) {
			case 0: "left";
			case 1: "down";
			case 2: "up";
			case 3: "right";
			default: "unknown";
		}
	}

	public static function getNoteIndex(direction:String):Int {
		return switch (direction) {
			case "left": 0;
			case "down": 1;
			case "up": 2;
			case "right": 3;
			default: -1;
		}
	}

	public static function openUrlPlease(url:String) {
		#if linux
		var cmd = Sys.command("xdg-open", [url]);
		if (cmd != 0) cmd = Sys.command("/usr/bin/xdg-open", [url]);
		Sys.command('/usr/bin/xdg-open', [url]);
		#else
		FlxG.openURL(url);
		#end
	}

	public static function wait(milliseconds:Int, callback:Void->Void):Void {
		Timer.delay(callback, milliseconds);
	}
}

class MapUtil {
	public static function hasKey<K, V>(map:Map<K, V>, key:K):Bool
		return map[key] != null;
}