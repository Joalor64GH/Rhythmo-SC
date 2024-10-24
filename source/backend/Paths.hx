package backend;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;

using haxe.io.Path;

enum SpriteSheetType {
	ASEPRITE;
	PACKER;
	SPARROW;
	TEXTURE_PATCHER_JSON;
	TEXTURE_PATCHER_XML;
}

@:keep
@:access(openfl.display.BitmapData)
class Paths {
	inline public static final DEFAULT_FOLDER:String = 'assets';

	public static var tempFramesCache:Map<String, FlxFramesCollection> = [];
	private static var trackedBitmaps:Map<String, BitmapData> = new Map();

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var localTrackedAssets:Array<String> = [];

	@:noCompletion private inline static function _gc(major:Bool) {
		#if (cpp || neko)
		Gc.run(major);
		#elseif hl
		Gc.major();
		#end
	}

	@:noCompletion public inline static function compress() {
		#if cpp
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif neko
		Gc.run(true);
		#end
	}

	public inline static function gc(major:Bool = false, repeat:Int = 1) {
		while (repeat-- > 0)
			_gc(major);
	}

	public static function clearUnusedMemory() {
		for (key in currentTrackedAssets.keys()) {
			if (!localTrackedAssets.contains(key)) {
				destroyGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
			}
		}
		compress();
		gc(true);
	}

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory() {
		for (key in FlxG.bitmap._cache.keys()) {
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}

		for (key => asset in currentTrackedSounds) {
			if (!localTrackedAssets.contains(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		localTrackedAssets = [];
		Assets.cache.clear("songs");
		gc(true);
		compress();
	}

	inline static function destroyGraphic(graphic:FlxGraphic) {
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

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
		if (!localTrackedAssets.contains(file))
			localTrackedAssets.push(file);
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
		return (FileSystem.exists(file(key))) ? File.getContent(file(key)) : null;
		#else
		return (Assets.exists(file(key))) ? Assets.getText(file(key)) : null;
		#end
	}

	inline static public function txt(key:String)
		return file('$key.txt');

	inline static public function json(key:String)
		return file('$key.json');

	inline static public function xml(key:String)
		return file('$key.xml');

	inline static public function script(key:String)
		return file('$key.hxs');

	static public function sound(key:String, ?cache:Bool = true):Sound
		return returnSound('sounds/$key', cache);

	inline static public function music(key:String, ?cache:Bool = true):Sound
		return returnSound('music/$key', cache);

	inline static public function song(key:String, ?cache:Bool = true):Sound
		return returnSound('songs/$key/music', cache);

	inline static public function formatToSongPath(path:String) {
		final invalidChars = ~/[~&;:<>#\s]/g;
		final hideChars = ~/[.,'"%?!]/g;

		return hideChars.replace(invalidChars.replace(path, '-'), '').trim().toLowerCase();
	}

	inline static public function chart(key:String)
		return file('songs/$key/chart.json');

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

	inline static public function image(key:String, ?cache:Bool = true):FlxGraphic
		return returnGraphic('images/$key', cache);

	inline static public function imageAlt(key:String)
		return file('images/$key.png');

	public static inline function spritesheet(key:String, ?cache:Bool = true, ?type:SpriteSheetType):FlxAtlasFrames {
		switch (type) {
			case ASEPRITE: 
				return FlxAtlasFrames.fromAseprite(image(key, cache), json('images/$key'));
			case PACKER: 
				return FlxAtlasFrames.fromSpriteSheetPacker(image(key, cache), txt('images/$key'));
			case SPARROW: 
				return FlxAtlasFrames.fromSparrow(image(key, cache), xml('images/$key'));
			case TEXTURE_PATCHER_JSON: 
				return FlxAtlasFrames.fromTexturePackerJson(image(key, cache), json('images/$key'));
			case TEXTURE_PATCHER_XML: 
				return FlxAtlasFrames.fromTexturePackerXml(image(key, cache), xml('images/$key'));
		}

		if (type == null) {
			type = SPARROW;
			return FlxAtlasFrames.fromSparrow(returnGraphic('images/errorSparrow', cache), xml('images/errorSparrow'));
		}

		return FlxAtlasFrames.fromSparrow(returnGraphic('images/errorSparrow', cache), xml('images/errorSparrow'));
	}

	public static function returnGraphic(key:String, ?cache:Bool = true):FlxGraphic {
		var path:String = file('$key.png');
		if (Assets.exists(path, IMAGE)) {
			if (!currentTrackedAssets.exists(path)) {
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path), false, path, cache);
				graphic.persist = true;
				currentTrackedAssets.set(path, graphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('oops! $key returned null');
		return null;
	}

	public static function returnSound(key:String, ?cache:Bool = true):Sound {
		if (Assets.exists(file('$key.ogg'), SOUND)) {
			var path:String = file('$key.ogg');
			if (!currentTrackedSounds.exists(path))
				currentTrackedSounds.set(path, Assets.getSound(path, cache));

			localTrackedAssets.push(path);
			return currentTrackedSounds.get(path);
		} else if (Assets.exists(file('$key.wav'), SOUND)) {
			var path:String = file('$key.wav');
			if (!currentTrackedSounds.exists(path))
				currentTrackedSounds.set(path, Assets.getSound(path, cache));

			localTrackedAssets.push(path);
			return currentTrackedSounds.get(path);
		}

		trace('oops! $key returned null');
		return null;
	}
}

typedef FileAssets = #if sys FileSystem; #else openfl.utils.Assets; #end