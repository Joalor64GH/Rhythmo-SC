package backend;

import openfl.media.Sound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

using haxe.io.Path;

class Paths {
	inline public static final DEFAULT_FOLDER:String = 'assets';

	private static var trackedBitmaps:Map<String, BitmapData> = new Map();
	private static var localTracked:Array<String> = [];

	public static function setBitmap(id:String, ?bitmap:BitmapData):BitmapData {
		if (!trackedBitmaps.exists(id) && bitmap != null)
			trackedBitmaps.set(id, bitmap);
		pushTracked(id);
		return trackedBitmaps.get(id);
	}

	public static function disposeBitmap(id:String) {
		var obj:Null<BitmapData> = trackedBitmaps.get(id);
		if (obj != null) {
			obj.dispose();
			obj.disposeImage();
			obj = null;
			trackedBitmaps.remove(id);
		}
	}

	public static function pushTracked(file:String) {
		if (!localTracked.contains(file))
			localTracked.push(file);
	}

	inline static public function exists(asset:String)
		return FileAssets.exists(asset);

	static public function getPath(folder:Null<String>, file:String) {
		if (folder == null)
			folder = DEFAULT_FOLDER;
		return folder + '/' + file;
	}

	static public function file(file:String, folder:String = DEFAULT_FOLDER) {
		if (#if sys FileSystem.exists(folder) && #end (folder != null && folder != DEFAULT_FOLDER))
			return getPath(folder, file);
		return getPath(null, file);
	}

	inline public static function getText(path:String):Array<String>
		return Assets.exists(path) ? [for (i in Assets.getText(path).trim().split('\n')) i.trim()] : [];

	static public function getTextFromFile(key:String):String {
		#if sys
		if (FileSystem.exists(file(key)))
			return File.getContent(file(key));
		#end

		return (Assets.exists(file(key))) ? Assets.getText(file(key)) : null;
	}

	inline static public function txt(key:String)
		return file('$key.txt');

	inline static public function sound(key:String, ?music:Bool = false, ?customPath:Bool = false):Dynamic {
		var base:String = '';

		if (!customPath)
			base = (!music) ? 'sounds/' : 'music/';

		var gamingPath = base + key + '.ogg';

		if (Cache.getFromCache(gamingPath, "sound") == null) {
			var sound:Sound = null;
			sound = Sound.fromFile("assets/" + gamingPath);
			Cache.addToCache(gamingPath, sound, "sound");
		}

		return Cache.getFromCache(gamingPath, "sound");
	}

	inline static public function soundRandom(key:String, min:Int, max:Int)
		return sound('$key${FlxG.random.int(min, max)}');

	inline static public function song(key:String)
		return sound('songs/$key/music', true, true);

	inline static public function formatToSongPath(path:String) {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	inline static public function chart(key:String)
		return file('songs/$key/chart.json');

	inline static public function script(key:String)
		return file('$key.hxs');

	inline static public function image(key:String, ?customPath:Bool = false):Dynamic {
		var png = (!customPath) ? file('images/$key') : file(key);

		if (FileSystem.exists(png + ".png")) {
			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return Cache.getFromCache(png, "image");
		}

		return null;
	}

	inline static public function font(key:String) {
		var path:String = file('fonts/$key');

		if (path.extension() == '') {
			if (exists(path.withExtension("ttf")))
				path = path.withExtension("ttf");
			else if (exists(path.withExtension("otf")))
				path = path.withExtension("otf");
		}

		return path;
	}

	inline static public function getSparrowAtlas(key:String, ?xmlCustom:Null<String>, ?customPath:Bool = false) {
		var png = (customPath) ? file(key) : file('images/$key');
		var xml = (customPath) ? file(xmlCustom) : (xmlCustom != null) ? file('images/$xmlCustom') : file('images/$png');

		if (FileSystem.exists(png + ".png") && FileSystem.exists(xml + ".xml")) {
			var xmlData = File.getContent(xml + ".xml");

			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return FlxAtlasFrames.fromSparrow(Cache.getFromCache(png, "image"), xmlData);
		}

		return FlxAtlasFrames.fromSparrow(image('errorSparrow'), file('images/errorSparrow.xml'));
	}

	inline static public function getPackerAtlas(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), file('images/$key.txt'));
}

typedef FileAssets = #if sys FileSystem; #else openfl.utils.Assets; #end