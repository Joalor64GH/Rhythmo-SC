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
	private static var customFontPath:String;

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

		var path:String = Paths.txt("languages/languagesList");
		if (Paths.exists(path)) {
			var listContent:String = Paths.getText(path);
			var languages:Array<String> = listContent.split('\n');

			for (language in languages) {
				var languageData:Dynamic = loadLanguageData(language.trim());
				data.set(language, languageData);
			}
		}

		loadCustomFont(DEFAULT_LANGUAGE);
	}

	private static function loadLanguageData(language:String):Dynamic {
		var jsonContent:String;

		try {
			jsonContent = Paths.getText(path(language));
		} catch (e:Dynamic) {
			trace('file not found: $e');
			jsonContent = Paths.getText(path(DEFAULT_LANGUAGE));
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

		loadCustomFont(newLanguage);
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

	public static function loadCustomFont(language:String):String {
		var path:String = Paths.file('languages/fonts/' + language);
		if (Paths.exists(path)) {
			trace('custom font loaded for $language: $path');
			return customFontPath = path;
		}

		return null;
	}

	public static function getCustomFont():String {
		return customFontPath;
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