# How to Use the Scripting System
This will teach you how to use Rhythmo's special scripting system. Basically, you can use this to make custom backgrounds, add special functions, make cool mechanics, etc.

Your script should either be located in `assets/scripts/[name].hxs`, or in `assets/songs/[your-song]/[name].hxs`.

## Imports
To import a class, use:
```hx
import('package.Class');
```

This is a list of the current Libraries/Classes that you can use:

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
* Song

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

function yourFunction() {
    // code goes here...
}
```

As long as you've done everything correctly, your script should functioning. Otherwise, report an issue.