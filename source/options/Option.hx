package options;

import haxe.Exception;

enum OptionType {
	Toggle;
	Integer(min:Int, max:Int, step:Int);
	Decimal(min:Float, max:Float, step:Float);
	Function;
	Choice(choices:Array<String>);
}

class Option {
	public var name:String;
	public var desc:String;
	public var type:OptionType;
	public var value:Dynamic;
	public var showPercentage:Bool = false;
	public var onChange:Dynamic->Void;

	public function new(name:String, desc:String, type:OptionType, value:Dynamic):Void {
		this.name = name;
		this.desc = desc;
		this.type = type;
		this.value = value;
	}

	public function changeValue(?direction:Int = 0):Void {
		switch (type) {
			case OptionType.Toggle:
				value = !value;
			case OptionType.Integer(min, max, step):
				value = Math.floor(FlxMath.bound(value + direction * step, min, max));
			case OptionType.Decimal(min, max, step):
				value = FlxMath.bound(value + direction * step, min, max);
			case OptionType.Choice(choices):
				value = choices[FlxMath.wrap(choices.indexOf(value) + direction, 0, choices.length - 1)];
			default:
				// nothing
		}

		if (type != OptionType.Function && onChange != null)
			onChange(value);
	}

	public function execute():Void {
		try {
			if (type == OptionType.Function && (value != null && Reflect.isFunction(value)))
				Reflect.callMethod(null, value, []);
		} catch (e:Exception)
			FlxG.log.error('Unable to call the function for "$name" option: ${e.message}');
	}

	public function toString():String {
		var formattedString:String = 'Error!';

		switch (type) {
			case OptionType.Toggle:
				formattedString = '$name: ${value ? 'On' : 'Off'}';
			case OptionType.Integer(_, _, _):
				formattedString = '$name: $value${showPercentage ? '%' : ''}';
			case OptionType.Decimal(_, _, _):
				formattedString = '$name: $value${showPercentage ? '%' : ''}';
			case OptionType.Choice(_):
				formattedString = '$name: $value';
			default:
				formattedString = name;
		}

		return formattedString;
	}
}