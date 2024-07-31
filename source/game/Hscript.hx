package game;

import hscript.*;

class Hscript extends FlxBasic {
	public var hscript:Interp;
	public var emulatedHscript:Array<String> = []; // this var is not doing anything

	public override function new(script:String) {
		super();
		hscript = new Interp();
		emulatedHscript.push(script);
	}

	public function runScript(script:String) {
		var parser = new hscript.Parser();

		try {
			var ast = parser.parseString(script);

			hscript.execute(ast);
		} catch (e) {
			Lib.application.window.alert(e.message, "HSCRIPT ERROR!1111");
		}
	}

	public function setVariable(name:String, val:Dynamic) {
		hscript.variables.set(name, val);
	}

	public function getVariable(name:String):Dynamic {
		return hscript.variables.get(name);
	}

	public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
		if (hscript == null)
			return null;

		if (hscript.variables.exists(funcName)) {
			var func = hscript.variables.get(funcName);
			if (args == null) {
				var result = null;
				try {
					result = func();
				} catch (e) {
					trace('$e');
				}
				return result;
			} else {
				var result = null;
				try {
					result = Reflect.callMethod(null, func, args);
				} catch (e) {
					trace('$e');
				}
				return result;
			}
		}
		return null;
	}

	public override function destroy() {
		super.destroy();
		hscript = null;
	}
}