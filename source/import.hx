#if !macro
// Default Imports
import flixel.*;
import flixel.util.*;
import flixel.math.*;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.*;
import flixel.input.keyboard.*;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import openfl.Lib;
import openfl.Assets;
import openfl.display.BitmapData;

import lime.app.Application;

import haxe.*;
import haxe.io.Path;

#if (sys || desktop)
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

// Game Imports
import states.*;
import substates.*;
import backend.*;
import modding.*;
import objects.*;

using Globals;
using StringTools;
using backend.Utilities;

#if !debug
@:noDebug
#end
#end