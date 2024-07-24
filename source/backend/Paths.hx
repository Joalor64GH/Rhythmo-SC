package backend;

import openfl.display.BitmapData;

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

	static public function getPath(folder:Null<String>, file:String)
	{
		if (folder == null) folder = DEFAULT_FOLDER;
		return folder + '/' + file;
	}

	static public function file(file:String, folder:String = DEFAULT_FOLDER) {
		if (#if sys FileSystem.exists(folder) && #end (folder != null && folder != DEFAULT_FOLDER))
			return getPath(folder, file);
		return getPath(null, file);
	}

	inline public static function getText(path:String):Array<String>
        return Assets.exists(path) ? [for (i in Assets.getText(path).trim().split('\n')) i.trim()] : [];

	inline static public function txt(key:String)
		return file('data/$key.txt');

	inline static public function xml(key:String)
		return file('data/$key.xml');

	inline static public function json(key:String)
		return file('data/$key.json');

	#if yaml
	inline static public function yaml(key:String)
		return file('data/$key.yaml');
	#end

	inline static public function video(key:String)
		return file('videos/$key.ogg');

	inline static public function sound(key:String)
		return file('sounds/$key.ogg');

	inline static public function soundRandom(key:String, min:Int, max:Int)
		return file('sounds/$key${FlxG.random.int(min, max)}.ogg');

	inline static public function music(key:String)
		return file('music/$key.ogg');

	inline static public function image(key:String)
		return file('images/$key.png');

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

	inline static public function getSparrowAtlas(key:String)
		return FlxAtlasFrames.fromSparrow(image(key), file('images/$key.xml'));

	inline static public function getPackerAtlas(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), file('images/$key.txt'));
}

typedef FileAssets = #if sys FileSystem; #else openfl.utils.Assets; #end