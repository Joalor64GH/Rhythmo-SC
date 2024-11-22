package substates;

class PromptSubState extends FlxSubState {
	var question:String;
	var callbackYes:Void->Void;
	var callbackNo:Void->Void;

	public function new(question:String, callbackYes:Void->Void, ?callbackNo:Void->Void) {
		super();

		this.question = question;
		this.callbackYes = callbackYes;
		this.callbackNo = callbackNo;

		var width:Float = FlxG.width * 0.75;
		var height:Float = FlxG.height * 0.5;

		var box:FlxSprite = new FlxSprite().makeGraphic(Std.int(width), Std.int(height), 0xFF000000);
		box.scrollFactor.set();
		box.screenCenter();
		add(box);

		var questionTxt:FlxText = new FlxText(box.x, box.y + 20, width, question);
		questionTxt.setFormat(Paths.font('vcr.ttf'), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		questionTxt.scrollFactor.set();
		add(questionTxt);

		var btnYes:FlxButton = new FlxButton(0, box.height / 2 + 200, Localization.get("yes"), () -> {
			if (callbackYes != null)
				callbackYes();
			close();
		});
		btnYes.screenCenter(X);
		btnYes.scale.set(2, 2);
		btnYes.label.scale.set(2, 2);
		btnYes.label.screenCenter(XY);
		add(btnYes);

		var btnNo:FlxButton = new FlxButton(0, btnYes.y + 50, Localization.get("no"), () -> {
			if (callbackNo != null)
				callbackNo();
			close();
		});
		btnNo.screenCenter(X);
		btnNo.scale.set(2, 2);
		btnNo.label.scale.set(2, 2);
		btnNo.label.screenCenter(XY);
		add(btnNo);
	}
}