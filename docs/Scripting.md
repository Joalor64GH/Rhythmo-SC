Scripts in Rhythmo can be active in only one song, or be applied globally to every song. You can use scripts to make custom backgrounds, add special functions, make cool mechanics, etc.

Your script should either be located in `assets/scripts/[name].hxs`, or in `assets/songs/[song-name]/[name].hxs`. <br>
However, if your script is a scripted state or substate, it should be located in `assets/classes/[name].hxs`.

## Limitations
The following are not supported:
* Keywords:
    * `package`
    * `import` (there's another function that emulates the purpose of this function)
    * `class`
    * `typedef`
    * `metadata`
    * `final`
* Wildcard imports
* Access modifiers (e.g., `private`, `public`)

## Default Variables
* `Function_Stop` - Cancels functions (e.g., `startCountdown`, `endSong`).
* `Function_Continue` - Continues the game like normal.
* `platform` - Returns the current platform (e.g., Windows, Linux).
* `version` - Returns the current game version.

## Default Functions
* `import` - See [Imports](https://github.com/Joalor64GH/Rhythmo-SC/wiki/Scripting#imports) for more.
* `trace(_)` - The equivalent of `trace` in normal Haxe.
* `stopScript()` - Stops the current script.
* `addScript(path:String)` - Adds a new script to `scriptArray` (Used in PlayState only).
* `importScript(source:String)` - Gives the given script's local functions and variables.

## Imports
To import a class, use:
```hx
import('package.Class');
```

To import an enumerator, use:
```hx
import('package.Enum');
```

To put an import under an alias name, use:
```hx
import('package.Class', 'Name');
```

You can basically use this to import any class/enum you'd like. <br>
Otherwise, here is a list of the current classes you can use that are already imported:

### Standard Haxe Classes
* `Array`
* `Bool`
* `Date`
* `DateTools`
* `Dynamic`
* `EReg`
* `Float`
* `Int`
* `Lambda`
* `Math`
* `Reflect`
* `Std`
* `String`
* `StringBuf`
* `StringTools`
* `Sys`
* `Type`
* `Xml`

### Game-Specific Classes
* `Achievements`
* `Application`
* `Assets`
* `Bar`
* `Conductor`
* `ExtendableState`
* `ExtendableSubState`
* `File`
* `FileSystem`
* `FlxAtlasFrames`
* `FlxBackdrop`
* `FlxBasic`
* `FlxCamera`
* `FlxColor`
    * Fun Fact, `FlxColor` is actually an abstract type which isn't normally supported by `hscript`. Luckily, I figured out a little workaround so you can still use `FlxColor` normally, or you can just use plain hex color values.
* `FlxEase`
* `FlxG`
* `FlxGroup`
* `FlxMath`
* `FlxObject`
* `FlxSave`
* `FlxSort`
* `FlxSound`
* `FlxSprite`
* `FlxSpriteGroup`
* `FlxStringUtil`
* `FlxText`
* `FlxTextBorderStyle`
* `FlxTimer`
* `FlxTween`
* `FlxTypedGroup`
* `GameSprite`
* `HighScore`
* `Input`
* `Json`
* `Lib`
* `Localization`
* `Main`
* `ModHandler`
* `Note`
* `Path`
* `Paths`
* `PlayState`
* `Rating`
* `SaveData`
* `ScriptedState`
* `ScriptedSubState`
* `Song`
* `Utilities`

## Templates
Some useful templates. For the default template, use [this](https://raw.githubusercontent.com/Joalor64GH/Rhythmo-SC/main/assets/scripts/template.hxs).

### FlxSprite
```hx
import('flixel.FlxSprite');
import('states.PlayState');

function create() {
	var spr:FlxSprite = new FlxSprite(0, 0).makeGraphic(50, 50, FlxColor.BLACK);
	PlayState.instance.add(spr);
}
```

### FlxText
```hx
import('flixel.text.FlxText');
import('states.PlayState');

function create() {
	var text:FlxText = new FlxText(0, 0, 0, "Hello World", 64);
	text.screenCenter();
	PlayState.instance.add(text);
}
```

### Parsing a JSON
```hx
import('sys.FileSystem');
import('sys.io.File');
import('haxe.Json');

var json:Dynamic;

function create() {
	if (FileSystem.exists('assets/data.json'))
		json = Json.parse(File.getContent('assets/data.json'));

	trace(json);
}
```

### Custom States/Substates
```hx
import('states.ScriptedState');
import('substates.ScriptedSubState');
import('backend.ExtendableState');
import('backend.Input');
import('flixel.FlxG');

var state = FlxG.state;

function update(elapsed:Float) {
	if (Input.justPressed('accept'))
		ExtendableState.switchState(new ScriptedState('name', [/* arguments, if any */])); // load custom state

	if (Input.justPressed('exit'))
		state.openSubState(new ScriptedSubState('name', [/* arguments, if any */])); // load custom substate
}
```

Additionally, if you want to load your custom state from the main menu, navigate to `assets/menuList.txt` and add in your state's name, as well as a main menu asset for it in `assets/images/menu/mainmenu/[name].png`.

And just in case your script doesn't load or something goes wrong, press `F4` to be sent to the main menu.

### Using Imported Scripts
Script 1:
```hx
// assets/helpers/spriteHandler.hxs
import('flixel.FlxSprite');
import('backend.Paths');
import('flixel.FlxG');

var state = FlxG.state;

function createSprite(x:Float, y:Float, graphic:String) {
	var spr:FlxSprite = new FlxSprite(x, y);
	spr.loadGraphic(Paths.image(graphic));
	state.add(spr);

	trace("sprite " + sprite + " created");
}
```

Script 2:
```hx
var otherScript = importScript('assets.helpers.spriteHandler');

function create() {
	otherScript.createSprite(0, 0, 'sprite');
}
```

As long as you've done everything correctly, your script should functioning. Otherwise, report an issue.