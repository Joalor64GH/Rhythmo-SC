# How to Add a Mod
This tutorial simply shows you how you can add your own mod.

## Creating the Folder
Create a folder in the `mods` folder and rename it to whatever you want.

Doing this manually isn't a problem, but it would be better and faster if you copy-and-pasted the Template.

![](https://github.com/user-attachments/assets/85d6cc54-72e0-406f-b5a0-131b65e32b62?raw=true)
![](https://github.com/user-attachments/assets/add932d1-8a09-40c8-ae2a-89d57ca1c9cf?raw=true)

## In-Game Mod Info

The info for a mod is stored in two files. Those two files are `_polymod_meta.json` and `_polymod_icon.png`.

### `_polymod_meta.json`
In `_polymod_meta.json`, you can define the mod name, the name of the author, etc.

Example:
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

### `_polymod_icon.png`
As for `_polymod_icon.png`, it's just a simple `.png` icon for the mod. Any square image is recommended. Just keep in mind that **whatever image it is, it will always be squished into a `75 x 75` resolution**.

If you've done everything correctly, your mod should appear in the Mods Menu. <br>
Then, you're basically good to go!

For further documentation, check out [polymod.io](https://polymod.io/docs/).

## Quick Example

Here's a quick example by [EliteMasterEric](https://twitter.com/EliteMasterEric) » [here](https://github.com/EnigmaEngine/ModCore-Tricky-Mod) «
