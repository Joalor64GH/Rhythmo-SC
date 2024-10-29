package backend;

import backend.Conductor.BPMChangeEvent;
import backend.Conductor.TimeScaleChangeEvent;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;

class ExtendableState extends FlxTransitionableState {
	var curBeat:Int = 0;
	var curStep:Int = 0;

	override public function new(?noTransition:Bool = false) {
		super();

		if (!InitialState.transitionsAllowed) {
			noTransition = true;
			InitialState.transitionsAllowed = true;
		}

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = noTransition;
		FlxTransitionableState.skipNextTransOut = noTransition;
	}

	override public function create() {
		super.create();
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

	public static function switchState(nextState:FlxState, ?noTransition:Bool = false) {
		FlxTransitionableState.skipNextTransIn = noTransition;
		FlxTransitionableState.skipNextTransOut = noTransition;

		FlxG.switchState(nextState);
	}

	public static function resetState() {
		FlxG.resetState();
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