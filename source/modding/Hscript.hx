package modding;

import hscript.*;

class Hscript extends FlxBasic {
	public var locals(get, set):Map<String, {r:Dynamic}>;

	function get_locals():Map<String, {r:Dynamic}> {
		@:privateAccess
		return interp.locals;
	}

	function set_locals(local:Map<String, {r:Dynamic}>) {
		@:privateAccess
		return interp.locals = local;
	}

	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public var parser:Parser = new Parser();
	public var interp:Interp = new Interp();

	public function new(file:String, ?execute:Bool = true) {
		super();

		parser.allowJSON = parser.allowTypes = parser.allowMetadata = true;
		parser.preprocesorValues = MacrosUtil.getDefines();

		setVariable('this', this);
		setVariable('import', function(daClass:String, ?asDa:String) { // to-do: wildcard imports or whatever they're called
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

		setVariable('trace', function(value:Dynamic) {
			trace(value);
		});

		setVariable('importScript', importScript);

		setVariable('stopScript', function() {
			this.destroy();
		});

		setVariable('Function_Stop', Function_Stop);
		setVariable('Function_Continue', Function_Continue);

		setVariable('Array', Array);
		setVariable('Bool', Bool);
		setVariable('Date', Date);
		setVariable('DateTools', DateTools);
		setVariable('Dynamic', Dynamic);
		setVariable('EReg', EReg);
		setVariable('Float', Float);
		setVariable('Int', Int);
		setVariable('Lambda', Lambda);
		setVariable('Math', Math);
		setVariable('Reflect', Reflect);
		setVariable('Std', Std);
		setVariable('StringBuf', StringBuf);
		setVariable('String', String);
		setVariable('StringTools', StringTools);
		setVariable('Sys', Sys);
		setVariable('Type', Type);
		setVariable('Xml', Xml);

		setVariable('Achievements', Achievements);
		setVariable('Application', Application);
		setVariable('Assets', Assets);
		setVariable('Bar', Bar);
		setVariable('Conductor', Conductor);
		setVariable('ExtendableState', ExtendableState);
		setVariable('ExtendableSubState', ExtendableSubState);
		#if sys
		setVariable('File', File);
		setVariable('FileSystem', FileSystem);
		#end
		setVariable('FlxAtlasFrames', FlxAtlasFrames);
		setVariable('FlxBackdrop', FlxBackdrop);
		setVariable('FlxBasic', FlxBasic);
		setVariable('FlxCamera', FlxCamera);
		setVariable('FlxEase', FlxEase);
		setVariable('FlxG', FlxG);
		setVariable('FlxGroup', FlxGroup);
		setVariable('FlxMath', FlxMath);
		setVariable('FlxObject', FlxObject);
		setVariable('FlxSave', FlxSave);
		setVariable('FlxSort', FlxSort);
		setVariable('FlxSound', FlxSound);
		setVariable('FlxSprite', FlxSprite);
		setVariable('FlxSpriteGroup', FlxSpriteGroup);
		setVariable('FlxStringUtil', FlxStringUtil);
		setVariable('FlxText', FlxText);
		setVariable('FlxTextBorderStyle', FlxTextBorderStyle);
		setVariable('FlxTimer', FlxTimer);
		setVariable('FlxTween', FlxTween);
		setVariable('FlxTypedGroup', FlxTypedGroup);
		setVariable('GameSprite', GameSprite);
		setVariable('HighScore', HighScore);
		setVariable('Input', Input);
		setVariable('Json', Json);
		setVariable('Lib', Lib);
		setVariable('Localization', Localization);
		setVariable('Main', Main);
		#if FUTURE_POLYMOD
		setVariable('ModHandler', ModHandler);
		#end
		setVariable('Note', Note);
		setVariable('Paths', Paths);
		setVariable('PlayState', PlayState);
		setVariable('Rating', Rating);
		setVariable('SaveData', SaveData);
		setVariable('ScriptedState', ScriptedState);
		setVariable('ScriptedSubState', ScriptedSubState);
		setVariable('Song', Song);
		setVariable('Utilities', Utilities);

		if (execute)
			this.execute(file);
	}

	public function execute(file:String, ?executeCreate:Bool = true):Void {
		try {
			interp.execute(parser.parseString(File.getContent(file)));
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');

		trace('Script Loaded Succesfully: $file');

		if (executeCreate)
			executeFunc('create', []);
	}

	public function setVariable(name:String, val:Dynamic):Void {
		try {
			interp?.variables.set(name, val);
			locals.set(name, {r: val});
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');
	}

	public function getVariable(name:String):Dynamic {
		try {
			if (locals.exists(name) && locals[name] != null)
				return locals.get(name).r;
			else if (interp.variables.exists(name))
				return interp?.variables.get(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');

		return null;
	}

	public function removeVariable(name:String):Void {
		try {
			interp?.variables.remove(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');
	}

	public function existsVariable(name:String):Bool {
		try {
			return interp?.variables.exists(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(e, 'Hscript Error!');

		return false;
	}

	public function executeFunc(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (existsVariable(funcName)) {
			try {
				return Reflect.callMethod(this, getVariable(funcName), args == null ? [] : args);
			} catch (e:Dynamic)
				Lib.application.window.alert(e, 'Hscript Error!');
		}

		return null;
	}

	public function importScript(source:String):Void {
		if (source == null)
			return;
		var name:String = StringTools.replace(source, '.', '/');
		var script:Hscript = new Hscript(name, false);
		script.execute(name, false);
		return script.getAll();
	}

	public function getAll():Void {
		var balls = {};

		for (i in locals.keys())
			Reflect.setField(balls, i, getVariable(i));
		for (i in interp.variables.keys())
			Reflect.setField(balls, i, getVariable(i));

		return balls;
	}

	override function destroy() {
		super.destroy();
		parser = null;
		interp = null;
	}
}