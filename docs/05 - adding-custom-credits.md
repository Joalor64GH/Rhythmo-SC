# How to Add Custom Credits
If you want to add your own credits to `CreditsState.hx`, this will show you how to.

## Adding Custom Credits
To add your custom credits, you first need to navigate to `assets/credits.json`. <br>
Then you can edit the following:
* `menuBG` - Your custom menu background.
* `menuBGColor` - The color of your custom background.
* `tweenColor` - If the colors should set to the user's colors or not.

Now to actually add your credits, use this template:
```json
{
    "sectionName": "Section",

    "name": "Name",
    "iconData": ["icon", 0, 0],
    "textData": ["Contribution", "Description"],
    "urlData": [
        ["Social", "https://anywhere.com/"]
    ],
    "colors": [255, 255, 255]
 }
 ```

Explanation:
* `sectionName` - This is optional, but this is simply a header you can place in a specific user block.
* `name` - Obviously the name of the person.
* `iconData` - This uses three parameters. The first one is the icon's filename, the second is the X offset, and the third is the Y offset (both are optional).
* `textData` - This contains the user's contribution (required) and their description (optional).
* `urlData` - You can use this to add social media links for a user if they have any.
* `colors` - This uses RGB values.