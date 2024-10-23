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

	public static function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals) tempMult *= 10;
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
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
}

class MapUtil {
	public static function hasKey<K, V>(map:Map<K,V>, key:K):Bool return map[key] != null;
}