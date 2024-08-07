package backend;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;

class Cache {
	public static var soundCache:Map<String, Sound> = [];
	public static var imageCache:Map<String, FlxGraphic> = [];

	public static function addToCache(key:String, value:Dynamic, cacheName:String) {
		var cache = convertStringToCache(cacheName);
		cache.set(key, value);
	}

	public static function getFromCache(key:String, cacheName:String) {
		var cache = convertStringToCache(cacheName);
		return cache.get(key);
	}

	public static function convertStringToCache(name:String):Dynamic {
		switch (name.toLowerCase()) {
			case "sound":
				return soundCache;
			case "image":
				return imageCache;
			default:
				return new Map<String, String>();
		}
	}

	public static function clearCaches() {
		for (key in imageCache.keys()) {
			if (key != null) {
				lime.utils.Assets.cache.clear(key);
				Assets.cache.clear(key);
				imageCache.remove(key);
			}
		}

		imageCache = [];

		for (key in soundCache.keys()) {
			if (key != null) {
				Assets.cache.clear(key);
				soundCache.remove(key);
			}
		}

		soundCache = [];
	}
}