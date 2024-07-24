package game;

class Conductor {
	public static var bpm(default, set):Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;

	public function new() {}

	inline public static function calculateCrochet(bpm:Float) {
		return (60 / bpm) * 1000;
	}

	public static function set_bpm(newBpm:Float) {
		crochet = calculateCrochet(newBpm);
		stepCrochet = crochet / 4;
		return bpm = newBpm;
	}
}