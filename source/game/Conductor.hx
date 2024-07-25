package game;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

typedef TimeScaleChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var timeScale:Array<Int>;
}

class Conductor {
	public static var bpm(default, set):Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000);

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var timeScaleChangeMap:Array<TimeScaleChangeEvent> = [];
	public static var timeScale:Array<Int> = [4, 4];

	public static var stepsPerSection:Int = 16;

	public function new() {}

	inline public static function calculateCrochet(bpm:Float) {
		return (60 / bpm) * 1000;
	}

	public static function recalculateStuff(?multi:Float = 1) {
		safeZoneOffset = Math.floor((safeFrames / 60) * 1000) * multi;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / timeScale[1];

		stepsPerSection = Math.floor((16 / timeScale[1]) * timeScale[0]);
	}

	public static function mapBPMChanges(song:SongData, ?songMultiplier:Float = 1.0) {
		bpmChangeMap = [];
		timeScaleChangeMap = [];

		var curBPM:Float = song.bpm;
		var curTimeScale:Array<Int> = timeScale;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (i in 0...song.notes.length) {
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;

				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};

				bpmChangeMap.push(event);
			}

			if (song.notes[i].changeTimeScale
				&& song.notes[i].timeScale[0] != curTimeScale[0]
				&& song.notes[i].timeScale[1] != curTimeScale[1])
			{
				curTimeScale = song.notes[i].timeScale;

				var event:TimeScaleChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					timeScale: curTimeScale
				};

				timeScaleChangeMap.push(event);
			}

			var deltaSteps:Int = Math.floor((16 / curTimeScale[1]) * curTimeScale[0]);
			totalSteps += deltaSteps;

			totalPos += ((60 / curBPM) * 1000 / curTimeScale[0]) * deltaSteps;
		}

		recalculateStuff(songMultiplier);
	}

	public static function set_bpm(newBpm:Float):Float {
		crochet = calculateCrochet(newBpm);
		stepCrochet = crochet / 4;
		return bpm = newBpm;
	}
}