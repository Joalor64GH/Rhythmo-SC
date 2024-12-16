package backend;

import backend.Conductor.BPMChangeEvent;

class ExtendableSubState extends FlxSubState {
	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	override function create() {
		super.create();
	}

	override function update(elapsed:Float) {
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
			stepHit();

		FlxG.stage.frameRate = SaveData.settings.framerate;

		super.update(elapsed);
	}

	private function updateBeat():Void {
		curBeat = Math.floor(curStep / (16 / Conductor.timeScale[1]));
	}

	private function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];

		Conductor.recalculateStuff();

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);

		updateBeat();
	}

	public function stepHit():Void {
		if (curStep % Conductor.timeScale[0] == 0)
			beatHit();
	}

	public function beatHit():Void {}

	public function multiAdd(basic:Array<FlxBasic>) {
		for (bsc in basic)
			add(bsc);
	}

	public function multiRemove(basic:Array<FlxBasic>) {
		for (bsc in basic)
			remove(bsc);
	}
}