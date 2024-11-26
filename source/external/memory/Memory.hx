package external.memory;

#if cpp
@:buildXml('<include name="../../../../source/external/memory/build.xml" />')
@:include("memory.h")
extern class Memory {
	@:native("getPeakRSS")
	public static function getPeakUsage():Float;

	@:native("getCurrentRSS")
	public static function getCurrentUsage():Float;
}
#else
class Memory {
	public static function getPeakUsage():Float
		return 0.0;

	public static function getCurrentUsage():Float
		return 0.0;
}
#end