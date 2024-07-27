package backend;

#if openfl
import openfl.system.Capabilities;
#end

typedef ApplicationConfig = {
	var languages:Array<String>;
	@:optional var directory:String;
	@:optional var default_language:String;
}

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

	public static function init(config:ApplicationConfig) {
		directory = config.directory != null ? config.directory : "languages";
		DEFAULT_LANGUAGE = config.default_language != null ? config.default_language : "en";
	
		loadLanguages(config.languages);
		switchLanguage(DEFAULT_LANGUAGE);
	}

	public static function loadLanguages(languages:Array<String>) {
		data = new Map<String, Dynamic>();

		for (language in languages) {
			var languageData:Dynamic = loadLanguageData(language);
			data.set(language, languageData);
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
	
		if (data == null) {
			trace("You haven't initialized the class!");
			return null;
		}
	
		if (languageData != null && Reflect.hasField(languageData, key)) {
			return Reflect.field(languageData, key);
		}
	
		return null;
	}

	private static function path(language:String) {
		var localDir = Path.join([directory, language + ".json"]);
		var path:String = Paths.file(localDir);
		return path;
	}
}