#if !macro
// Default Imports
import flixel.*;
import flixel.util.*;
import flixel.math.*;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxRuntimeShader;
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
import flixel.ui.FlxButton;

import openfl.Lib;
import openfl.Assets;
import openfl.media.Sound;
import openfl.system.System;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import lime.app.Application;

import haxe.*;
import haxe.io.Path;

#if sys
import sys.*;
import sys.io.*;
#end

// Game Imports
import states.*;
import substates.*;
import backend.*;
import modding.*;
import objects.*;
import shaders.*;

using StringTools;
using backend.Utilities;
using backend.Utilities.MapUtil;

#if !debug
@:noDebug
#end
#end