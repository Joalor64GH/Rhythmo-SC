package backend;

import backend.Conductor.BPMChangeEvent;
import backend.Conductor.TimeScaleChangeEvent;
import flixel.addons.transition.FlxTransitionableState;

class ExtendableState extends FlxTransitionableState {
	var curBeat:Int = 0;
	var curStep:Int = 0;

	override public function create() {
		super.create();

		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CoolTransition(0.5, true));
		FlxTransitionableState.skipNextTransOut = false;
	}

	override public function update(elapsed:Float) {
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
			stepHit();

		if (FlxG.stage != null)
			FlxG.stage.frameRate = SaveData.settings.framerate;

		super.update(elapsed);
	}

	public static function switchState(nextState:FlxState = null) {
		if (nextState == null)
			nextState = FlxG.state;
		if (nextState == FlxG.state) {
			resetState();
			return;
		}

		if (FlxTransitionableState.skipNextTransIn)
			FlxG.switchState(nextState);
		else
			startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() {
		if (FlxTransitionableState.skipNextTransIn)
			FlxG.resetState();
		else
			startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function startTransition(nextState:FlxState = null) {
		if (nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new CoolTransition(0.35, false));
		if (nextState == FlxG.state) {
			CoolTransition.finishCallback = function() {
				FlxG.resetState();
			};
		} else {
			CoolTransition.finishCallback = function() {
				FlxG.switchState(nextState);
			};
		}
	}

	function updateBeat():Void {
		curBeat = Math.floor(curStep / Conductor.timeScale[1]);
	}

	function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];

		var dumb:TimeScaleChangeEvent = {
			stepTime: 0,
			songTime: 0,
			timeScale: [4, 4]
		};

		var lastTimeChange:TimeScaleChangeEvent = dumb;

		for (i in 0...Conductor.timeScaleChangeMap.length)
			if (Conductor.songPosition >= Conductor.timeScaleChangeMap[i].songTime)
				lastTimeChange = Conductor.timeScaleChangeMap[i];

		if (lastTimeChange != dumb)
			Conductor.timeScale = lastTimeChange.timeScale;

		var multi:Float = 1;

		if (FlxG.state == PlayState.instance)
			multi = PlayState.songMultiplier;

		Conductor.recalculateStuff(multi);

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