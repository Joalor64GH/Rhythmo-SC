package backend;

import polymod.Polymod;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules;
import polymod.util.VersionUtil;

class ModHandler {
	private static final MOD_DIR:String = 'mods';

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

	public static function reload():Void {
		Polymod.onError = function(error:PolymodError):Void {
			switch (error.severity) {
				case NOTICE:
					trace(error.message);
				case WARNING:
					trace(error.message);
				case ERROR:
					trace(error.message);
			}
		}
		
		final loadedModlist:PolymodParams = {
			modRoot: MOD_DIR,
			dirs: getMods(),
			framework: OPENFL,
			parseRules: getParseRules(),
			extensionMap: extensions,
			/*frameworkParams: {
				assetLibraryPaths: [
					"default" => "./assets"
				]
			},*/
			ignoredFiles: Polymod.getDefaultIgnoreList()
		};

		final appVersion:Null<String> = Lib.application.meta?.get('version');
		if (appVersion != null)
			polymodParams.apiVersionRule = VersionUtil.anyPatch(appVersion);

		Polymod.init(polymodParams);

		if (loadedModlist == null) return;

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

		final daList:Array<String> = [];

		trace('Searching for Mods...');

		final scanParams:ScanParams = {modRoot: MOD_DIR};

		final appVersion:Null<String> = Lib.application.meta?.get('version');
		if (appVersion != null)
			scanParams.apiVersionRule = VersionUtil.anyPatch(appVersion);

		for (i in Polymod.scan(scanParams)) {
			trackedMods.push(i);
			if (!FlxG.save.data.disabledMods.contains(i.id))
				daList.push(i.id);
		}

		if (daList != null && daList.length > 0)
			trace('Found ${daList.length} new mods.');

		return daList != null && daList.length > 0 ? daList : [];
	}

	public static function getParseRules():ParseRules {
		final output:ParseRules = ParseRules.getDefault();
		output.addType("txt", TextFileFormat.LINES);
		output.addType("hxs", TextFileFormat.PLAINTEXT);
		return output != null ? output : null;
	}
}