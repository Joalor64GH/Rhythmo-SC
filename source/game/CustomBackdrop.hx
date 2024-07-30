package game;

class CustomBackdrop extends FlxBackdrop {
	private var oscillationSpeed:Float;
	private var oscillationAmplitude:Float;
	private var initialY:Float;

	public function new(graphic:Dynamic) {
		super(graphic);
		oscillationSpeed = 1;
		oscillationAmplitude = 20;
		initialY = y;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var oscillation:Float = Math.sin(elapsed * oscillationSpeed) * oscillationAmplitude;
		y = initialY + oscillation;
	}

	public function setOscillation(speed:Float, amplitude:Float):Void {
		oscillationSpeed = speed;
		oscillationAmplitude = amplitude;
	}
}