package game;

import hscript.*;

class Hscript extends FlxBasic {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public var parser:Parser;
	public var interp:Interp;

	public var emulatedHscript:Array<String> = []; // this var is not doing anything

	public function new(file:String, ?execute:Bool = true) {
		super();

		parser = new Parser();
		parser.allowJSON = parser.allowTypes = parser.allowMetadata = true;

		interp = new Interp();

		setVariable('this', this);
		setVariable('import', function(daClass:String, ?asDa:String) {
			final splitClassName:Array<String> = [for (e in daClass.split('.')) e.trim()];
			final className:String = splitClassName.join('.');
			final daClass:Class<Dynamic> = Type.resolveClass(className);
			final daEnum:Enum<Dynamic> = Type.resolveEnum(className);

			if (daClass == null && daEnum == null)
				Lib.application.window.alert('Class / Enum at $className does not exist.', 'Hscript Error!');
			else {
				if (daEnum != null) {
					var daEnumField = {};
					for (daConstructor in daEnum.getConstructors())
						Reflect.setField(daEnumField, daConstructor, daEnum.createByName(daConstructor));

					if (asDa != null && asDa != '')
						setVariable(asDa, daEnumField);
					else
						setVariable(splitClassName[splitClassName.length - 1], daEnumField);
				} else {
					if (asDa != null && asDa != '')
						setVariable(asDa, daClass);
					else
						setVariable(splitClassName[splitClassName.length - 1], daClass);
				}
			}
		});

		setVariable('Function_Stop', Function_Stop);
		setVariable('Function_Continue', Function_Continue);

		setVariable('Date', Date);
		setVariable('DateTools', DateTools);
		setVariable('EReg', EReg);
		setVariable('Lambda', Lambda);
		setVariable('Math', Math);
		setVariable('Reflect', Reflect);
		setVariable('Std', Std);
		setVariable('StringBuf', StringBuf);
		setVariable('StringTools', StringTools);
		setVariable('Sys', Sys);
		setVariable('Type', Type);
		setVariable('Xml', Xml);

		setVariable('Application', Application);
		setVariable('Conductor', Conductor);
		setVariable('ExtendableState', ExtendableState);
		setVariable('ExtendableSubState', ExtendableSubState);
		setVariable('FlxBar', FlxBar);
		setVariable('FlxBasic', FlxBasic);
		setVariable('FlxCamera', FlxCamera);
		setVariable('FlxColor', FlxColor);
		setVariable('FlxEase', FlxEase);
		setVariable('FlxG', FlxG);
		setVariable('FlxGroup', flixel.group.FlxGroup);
		setVariable('FlxMath', FlxMath);
		setVariable('FlxObject', FlxObject);
		setVariable('FlxSave', FlxSave);
		setVariable('FlxSound', FlxSound);
		setVariable('FlxSprite', FlxSprite);
		setVariable('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
		setVariable('FlxText', FlxText);
		setVariable('FlxTextBorderStyle', FlxTextBorderStyle);
		setVariable('FlxTimer', FlxTimer);
		setVariable('FlxTween', FlxTween);
		setVariable('FlxTypedGroup', FlxTypedGroup);
		setVariable('FlxTypedSpriteGroup', flixel.group.FlxTypedSpriteGroup);
		setVariable('game', PlayState.instance);
		setVariable('Input', Input);
		setVariable('Lib', Lib);
		setVariable('Localization', Localization);
		setVariable('Main', Main);
		setVariable('Note', Note);
		setVariable('Paths', Paths);
		setVariable('PlayState', PlayState);
		setVariable('SaveData', SaveData);

		if (execute)
			this.execute(file);

		emulatedHscript.push(file);
	}

	public function execute(file:String, ?executeCreate:Bool = true):Void {
		try {
			interp.execute(parser.parseString(Assets.getText(file)));
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');

		trace('Script Loaded Succesfully: $file');

		if (executeCreate)
			executeFunc('create', []);
	}

	public function setVariable(name:String, val:Dynamic):Void {
		if (interp == null)
			return;

		try {
			interp.variables.set(name, val);
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');
	}

	public function getVariable(name:String):Dynamic {
		if (interp == null)
			return null;

		try {
			return interp.variables.get(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');

		return null;
	}

	public function removeVariable(name:String):Void {
		if (interp == null)
			return;

		try {
			interp.variables.remove(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');
	}

	public function existsVariable(name:String):Bool {
		if (interp == null)
			return false;

		try {
			return interp.variables.exists(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');

		return false;
	}

	public function executeFunc(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null)
			return null;

		if (existsVariable(funcName)) {
			try {
				return Reflect.callMethod(this, getVariable(funcName), args == null ? [] : args);
			} catch (e:Dynamic)
				Lib.application.window.alert(e, 'Hscript Error!');
		}

		return null;
	}

	override function destroy() {
		super.destroy();
		parser = null;
		interp = null;
	}
}