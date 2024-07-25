package backend;

typedef RatingData = {
    var name:String;
    var score:Int;
    var hitWindow:Int;
}

class Rating extends GameSprite {
    public var name:String = '';
    public var score:Int = 350;
    public var hitWindow:Null<Int> = 0;

    public function new(x:Float, y:Float, rating:RatingData) {
        super(x, y);

        this.name = rating.name;
        this.score = rating.score;
        this.hitWindow = rating.hitWindow;
        if (hitWindow == null) hitWindow = 0;

        loadGraphic(Paths.image('ui/$name'));
    }
}