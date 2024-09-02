package backend;

#if FUTURE_POLYMOD
import polymod.Polymod;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules;
#end

class ModHandler {
	private static final MOD_DIR:String = 'mods';

	#if FUTURE_POLYMOD
	private static final extensions:Map<String, PolymodAssetType> = [
		'ogg' => AUDIO_GENERIC,
		'png' => IMAGE,
		'xml' => TEXT,
		'json' => TEXT,
		'txt' => TEXT,
		'hxs' => TEXT,
		'ttf' => FONT,
		'otf' => FONT
	];

	public static var trackedMods:Array<ModMetadata> = [];
	#end

	public static function reload():Void {
		#if FUTURE_POLYMOD
		trace('Reloading Polymod...');
		loadMods(getMods());
		#else
		trace("Polymod reloading is not supported on your Platform!");
		#end
	}

	#if FUTURE_POLYMOD
	public static function loadMods(folders:Array<String>):Void {
		var loadedModlist:Array<ModMetadata> = Polymod.init({
			modRoot: MOD_DIR,
			dirs: folders,
			framework: OPENFL,
			apiVersion: Lib.application.meta.get('version'),
			errorCallback: onError,
			parseRules: getParseRules(),
			extensionMap: extensions,
			frameworkParams: {
				assetLibraryPaths: [
					"fonts" => "assets/fonts",
					"images" => "assets/images",
					"languages" => "assets/languages",
					"music" => "assets/music",
					"scripts" => "assets/scripts",
					"songs" => "assets/songs",
					"sounds" => "assets/sounds"
				]
			},
			ignoredFiles: Polymod.getDefaultIgnoreList()
		});

		trace('Loading Successful, ${loadedModlist.length} / ${folders.length} new mods.');

		for (mod in loadedModlist)
			trace('Name: ${mod.title}, [${mod.id}]');
	}

	public static function getMods():Array<String> {
		trackedMods = [];

		if (FlxG.save.data.disabledMods == null) {
			FlxG.save.data.disabledMods = [];
			FlxG.save.flush();
		}

		var daList:Array<String> = [];

		trace('Searching for Mods...');

		for (i in Polymod.scan(MOD_DIR, '*.*.*', onError)) {
			trackedMods.push(i);
			if (!FlxG.save.data.disabledMods.contains(i.id))
				daList.push(i.id);
		}

		trace('Found ${daList.length} new mods.');

		return daList;
	}

	public static function getParseRules():ParseRules {
		final output:ParseRules = ParseRules.getDefault();
		output.addType("txt", TextFileFormat.LINES);
		output.addType("hxs", TextFileFormat.PLAINTEXT);
		output.addType("json", new backend.ModHandler.JsonTools());
		return output;
	}

	static function onError(error:PolymodError):Void {
		switch (error.severity) {
			case NOTICE:
				trace(error.message);
			case WARNING:
				trace(error.message);
			case ERROR:
				trace(error.message);
		}
	}
	#end
}

class JsonTools extends polymod.format.ParseRules.JSONParseFormat {
	override private function _mergeObjects(a:Dynamic, b:Dynamic, signatureSoFar:String = ''):Dynamic {
		if (Std.isOfType(a, Array) && Std.isOfType(b, Array)) {
			var c:Array<Dynamic> = [];

			var d:Array<Dynamic> = a;
			var e:Array<Dynamic> = b;

			for (x in d) {
				c.push(x);
			}

			for (x in e) {
				c.push(x);
			}

			return c;
		} else if (!Std.isOfType(a, Array) && !Std.isOfType(b, Array)) {
			var aPrimitive = isPrimitive(a);
			var bPrimitive = isPrimitive(b);

			if (aPrimitive && bPrimitive) {
				return b;
			} else if (aPrimitive != bPrimitive) {
				return a;
			} else {
				for (field in Reflect.fields(b)) {
					if (Reflect.hasField(a, field)) {
						var aValue = Reflect.field(a, field);
						var bValue = Reflect.field(b, field);
						var mergedValue = copyVal(_mergeObjects(aValue, bValue, '$signatureSoFar.$field'));

						Reflect.setField(a, field, mergedValue);
					} else {
						Reflect.setField(a, field, Reflect.field(b, field));
					}
				}
			}
		} else {
			var aArr = Std.isOfType(a, Array) ? 'array' : 'object';
			var bArr = Std.isOfType(b, Array) ? 'array' : 'object';

			Polymod.warning(MERGE, "JSON can't merge @ (" + signatureSoFar + ") because base is (" + aArr + ") but payload is (" + bArr + ')');
		}

		return a;
	}
}