# How to Use the Scripting System
This will teach you how to use Rhythmo's special scripting system. Basically, you can use this to make custom backgrounds, add special functions, make cool mechanics, etc.

Your script should either be located in `assets/scripts/[name].hxs`, or in `assets/songs/[your-song]/[name].hxs`. <br>
However, if your script is a scripted state or substate, it should be located in `assets/classes/[name].hxs`.

**NOTE: These Haxe syntaxes are not supported in hscript**:
* `package`
* `import` (there's another function that emulates the purpose of this function)
* `class`
* `typedef`
* `metadata`

## Default Variables
* `Function_Stop` - Cancels functions (e.g., `startCountdown`, `endSong`)
* `Function_Continue` - Continues the game like normal
* `platform` - Returns the current platform

## Default Functions
* `import` - See [Imports](https://github.com/Joalor64GH/Rhythmo-SC/blob/main/docs/01%20-%20scripting.md#imports) for more.
* `trace` - The equivalent of `trace` in normal Haxe.
* `stopScript` - Stops the current script.
* `addScript` - Adds a new script to `scriptArray`.

## Imports
To import a class, use:
```hx
import('package.Class');
```

To import an enumerator, use:
```hx
import('package.Enum');
```

To emulate `as`, use:
```hx
import('package.Class', 'Name');
```

You can basically use this to import any class/enum you'd like. <br>
Otherwise, here is a list of the current classes you can use that are already imported:

### Standard Haxe Classes
* Array
* Bool
* Date
* DateTools
* Dynamic
* EReg
* Float
* Int
* Lambda
* Math
* Reflect
* Std
* String
* StringBuf
* StringTools
* Sys
* Type
* Xml

### Game-Specific Classes
* Achievements
* Application
* Assets
* Bar
* Conductor
* ExtendableState
* ExtendableSubState
* File
* FileSystem
* FlxAtlasFrames
* FlxBackdrop
* FlxBasic
* FlxCamera
* FlxColor
* FlxEase
* FlxG
* FlxGroup
* FlxMath
* FlxObject
* FlxSave
* FlxSort
* FlxSound
* FlxSprite
* FlxSpriteGroup
* FlxStringUtil
* FlxText
* FlxTextBorderStyle
* FlxTimer
* FlxTween
* FlxTypedGroup
* GameSprite
* HighScore
* Input
* Json
* Lib
* Localization
* Main
* ModHandler
* Note
* Path
* Paths
* PlayState
* Rating
* SaveData
* ScriptedState
* ScriptedSubState
* Song
* Utilities

Additionally, if you want to import another script, use:
```hx
importScript('path.script');
```

## Templates
Some useful templates. For the default template, use [this](/assets/scripts/template.hxs).

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

### Adding a new function
```hx
function create() {
    yourFunction();
}

function yourFunction(/* arguments, if any */) {
    // code goes here...
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
        ExtendableState.switchState(new ScriptedState('name')); // load custom state
    
    if (Input.justPressed('exit'))
        state.openSubState(new ScriptedSubState('name', [])); // load custom substate
}
```

Additional template for scripted substates:
```hx
function new(/* arguments, if any */) {
    // code goes here...
}
```

Also, if you want to load your custom state from the main menu, navigate to `assets/menuList.txt` and add in your state's name, as well as a main menu asset for it in `assets/images/menu/mainmenu/[name].png`.

### Using Imported Scripts
Script 1:
```hx
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