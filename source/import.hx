#if !macro
// Default Imports
import flixel.*;
import flixel.util.*;
import flixel.math.*;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import openfl.Lib;
import openfl.Assets;
import openfl.system.System;

import haxe.*;
import haxe.io.Path;

#if (sys || desktop)
import sys.io.File;
import sys.FileSystem;
#elseif js
import js.html.*;
#else
import openfl.utils.Assets;
#end

// Game Imports
import game.*;
import states.*;
import backend.*;

using Globals;
using StringTools;

#if !debug
@:noDebug
#end
#end