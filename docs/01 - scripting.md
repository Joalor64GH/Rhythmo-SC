# How to Use the Scripting System
This will teach you how to use Rhythmo's special scripting system. Basically, you can use this to make custom backgrounds, add special functions, etc.

Your script should either be located in `assets/scripts/[name].hxs`, or in `assets/songs/[your-song]/script.hxs`.

## Imports
To import a class, use:
```hx
import('package.Class');
```

This is a list of the current Libs/Classes that you can use:

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
Some templates that are useful.

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
    var text:FlxText = new FlxText(0, 0, 0, "text here lol", 64);
    text.screenCenter();
    PlayState.instance.add(text);
}
```