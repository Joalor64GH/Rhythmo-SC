## Credits Data
In `assets/credits.json`, you can edit the following fields:
* `menuBG` - Your custom menu background.
* `menuBGColor` - The color of your custom background (`[R, G, B]`).
* `tweenColor` - If the colors should set to the user's colors or not.

Then, in the `users` array, copy-and-paste this credit block:
```json
{
    "sectionName": "Section",

    "name": "Name",
    "iconData": ["icon", 0, 0],
    "textData": ["Contribution", "Description"],
    "urlData": [
        ["Website", "https://name.com/"],
        ["Twitter", "https://twitter.com/placeholder"]
    ],
    "colors": [255, 255, 255]
 }
 ```

You can then edit the following:
* `sectionName` *(optional)* - A header you can place in a specific user block.
* `name` - The user's name.
* `iconData` - An array with the filename for their icon, and optional X and Y offsets for positioning the icon.
* `textData` - Includes the user's contribution and an optional description.
* `urlData` - A list of links related to the user. Each entry is an array: the first element is the platform name, and the second is the URL, or you can set it to `nolink`.
* `colors` - An array using RGB values to set the background to a custom color (`[R, G, B]`).