package backend;

import backend.Conductor.BPMChangeEvent;
import backend.Conductor.TimeScaleChangeEvent;
import flixel.addons.transition.FlxTransitionableState;

class ExtendableState extends FlxState {
	public var curBeat:Int = 0;
	public var curStep:Int = 0;

	override function create() {
		super.create();

		if (!FlxTransitionableState.skipNextTransOut) {
			var cam:FlxCamera = new FlxCamera();
			cam.bgColor.alpha = 0;
			FlxG.cameras.add(cam, false);
			cam.fade(FlxColor.BLACK, 0.7, true, function() {
				FlxTransitionableState.skipNextTransOut = false;
			});
		} else
			FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float) {
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
			stepHit();

		if (FlxG.stage != null)
			FlxG.stage.frameRate = SaveData.settings.framerate;

		#if debug
		if (FlxG.keys.justPressed.F5)
			FlxG.resetState();
		#end

		super.update(elapsed);
	}

	public static function switchState(nextState:FlxState) {
		if (!FlxTransitionableState.skipNextTransIn) {
			var cam:FlxCamera = new FlxCamera();
			cam.bgColor.alpha = 0;
			FlxG.cameras.add(cam, false);
			cam.fade(FlxColor.BLACK, 0.7, false, function() {
				FlxG.switchState(nextState);
				FlxTransitionableState.skipNextTransIn = false;
			});
		} else {
			FlxG.switchState(nextState);
			FlxTransitionableState.skipNextTransIn = false;
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