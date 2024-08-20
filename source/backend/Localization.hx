package backend;

#if openfl
import openfl.system.Capabilities;
#end

/**
 * A simple localization system.
 * Please credit me if you use it!
 * @author Joalor64GH
 */
class Localization {
	private static final DEFAULT_DIR:String = "languages";

	private static var data:Map<String, Dynamic>;
	private static var currentLanguage:String;

	public static var DEFAULT_LANGUAGE:String = "en";
	public static var directory:String = DEFAULT_DIR;

	public static var systemLanguage(get, never):String;

	public static function get_systemLanguage() {
		#if openfl
		return Capabilities.language;
		#else
		return throw "This Variable is for OpenFl only!";
		#end
	}

	public static function loadLanguages() {
		data = new Map<String, Dynamic>();

		var path:String = Paths.file("languages/languagesList.txt");
		if (FileSystem.exists(path)) {
			var listContent:String = File.getContent(path);
			var languages:Array<String> = listContent.split('\n');

			for (language in languages) {
				var languageData:Dynamic = loadLanguageData(language.trim());
				data.set(language, languageData);
			}
		}
	}

	private static function loadLanguageData(language:String):Dynamic {
		var jsonContent:String;

		try {
			#if sys
			jsonContent = File.getContent(path(language));
			#else
			jsonContent = Assets.getText(path(language));
			#end
		} catch (e) {
			trace('file not found: $e');
			#if sys
			jsonContent = File.getContent(path(DEFAULT_LANGUAGE));
			#else
			jsonContent = Assets.getText(path(DEFAULT_LANGUAGE));
			#end
		}

		return Json.parse(jsonContent);
	}

	public static function switchLanguage(newLanguage:String) {
		if (newLanguage == currentLanguage)
			return;

		var languageData:Dynamic = loadLanguageData(newLanguage);

		currentLanguage = newLanguage;
		data.set(newLanguage, languageData);
		trace('Language changed to $currentLanguage');
	}

	public static function get(key:String, ?language:String):String {
		var targetLanguage:String = language != null ? language : currentLanguage;
		var languageData = data.get(targetLanguage);
		final field:String = Reflect.field(languageData, key);

		if (data != null && data.exists(targetLanguage))
			if (languageData != null && Reflect.hasField(languageData, key))
				return field;

		return field != null ? field : 'missing key: $key';
	}

	private static function path(language:String) {
		var localDir = Path.join([directory, language + ".json"]);
		var path:String = Paths.file(localDir);
		return path;
	}
}

class Locale {
	public var lang:String;
	public var code:String;

	public function new(lang:String, code:String) {
		this.lang = lang;
		this.code = code;
	}
}