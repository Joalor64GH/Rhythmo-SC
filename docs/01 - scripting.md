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

## Imports
To import a class, use:
```hx
import('package.Class');
```

This is a list of the current Libraries/Classes that you can use:

**NOTE: These classes are already imported anyways.**
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
* Note
* Paths
* PlayState
* Rating
* SaveData
* ScriptedState
* ScriptedSubState
* Song
* Utilities

## Templates
Some useful templates. For the default template, use [this](/assets/scripts/template.hxs).

### FlxSprite
```hx
import('flixel.FlxSprite');
import('states.PlayState');

function create() {
    var spr:FlxSprite = new FlxSprite(0, 0).makeGraphic(50, 50, 0xFF000000);
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
    
    if (Input.justPressed('accept'))
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

As long as you've done everything correctly, your script should functioning. Otherwise, report an issue.