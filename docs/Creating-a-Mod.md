## Creating the Folder
Create a folder in the `mods/` folder and rename it to whatever you want. <br>
Doing this manually isn't a problem, but it would be better and faster if you copy-and-pasted the `template` folder.

![](https://github.com/user-attachments/assets/85d6cc54-72e0-406f-b5a0-131b65e32b62?raw=true)
![](https://github.com/user-attachments/assets/add932d1-8a09-40c8-ae2a-89d57ca1c9cf?raw=true)

## Mod Metadata
The mod metadata comes in two files. Those two files are `_polymod_meta.json` and `_polymod_icon.png`.

### `_polymod_meta.json` (Required)
In `_polymod_meta.json`, you can define the mod name, the name of the author, etc.

Here's an example of a valid mod metadata file:
```json
{
	"title": "Template",
	"description": "Mod Description.",
	"author": "You!",
	"api_version": "1.0.0",
	"mod_version": "1.0.0",
	"license": "Apache 2.0"
}
```

Note that both `api_version` and `mod_version` should use valid [Semantic Versioning 2.0.0](https://semver.org/) values.

### `_polymod_icon.png` (Optional)
As for `_polymod_icon.png`, it's just a simple `.png` icon for the mod. Any square image is recommended, preferably `150 x 150`. Just keep in mind that **whatever image it is, it will always be squished into a `75 x 75` resolution**.

If you've done everything correctly, your mod should appear in the Mods Menu. <br>
Then, you're basically good to go!

## Mod Structure
Each folder in your mod should be used as follows:
* `_append` - Modify existing files without actually replacing them.
* `achievements` - For storing achievement data. Each achievement should be listed in `achList.txt`.
* `classes` - Scripted States and Substates.
* `fonts` - Font files. Pretty self-explanatory.
* `images` - All images in your mod.
	* `images/achievements` - The icons for your achievemnts.
	* `images/covers` - The covers for your songs.
	* `images/credits` - Used for credit icons.
	* `images/gameplay` - Used for gameplay UI.
	* `images/menu` - Used for menu assets.
* `languages` - For storing language data.
* `music` - Non-gameplay related music.
* `scripts` - Scripts that run on every song.
* `shaders` - `.frag` or `.vert` shader file that create cool immersive visuals.
* `songs` - Songs used for gameplay.
	* `songs/[song-name]/chart.json` - Your song's chart.
	* `songs/[song-name]/music.ogg` - Your song's music. Can also be a `.wav`.
	* `songs/[song-name]/[script-name].hxs` or `songs/[song-name]/[script-name].hxc` - Song-specific script(s).
* `sounds` - All sound effects.

Also, when it's neccessary, delete any folders you don't need.

For further documentation, check out [polymod.io](https://polymod.io/docs/).

## Quick Example
Here's a quick example by [EliteMasterEric](https://twitter.com/EliteMasterEric) » [here](https://github.com/EnigmaEngine/ModCore-Tricky-Mod) «