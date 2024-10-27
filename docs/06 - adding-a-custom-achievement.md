# How to Add a Custom Achievement
The tutorial will show you how to add your own custom achievement.

## Adding your Achievement
Firstly, you need a json file for your achievement. Copy this template:
```json
{
    "name": "Name",
    "desc": "Description",
    "hint": "Hint"
}
```

Then, for your achievement to actually be loaded, navigate to `assets/achievements/achList.txt` and add it there. <br>
Keep in mind the name has to be all lowercase.

Now, you simply need an icon for your achievement. Your icon should be in `assets/images/achievements/[name].png`. <br>
I recommend that the image's size should be a square, preferably `150 x 150`.

## Unlocking your Achievement
To actually be able to unlock your custom achievement, you can do it through [scripting](./01%20-%20scripting.md). <br>
Example:
```hx
import('states.PlayState');
import('backend.Achievements');

var condition:Bool = false;

function update(elapsed:Float) {
    if (PlayState.instance.score > 9000)
        condition = true;
}

function endSong() {
    if (condition) {
        Achievements.unlock('over_nine_thousand', {
            date: Date.now(),
            song: PlayState.song.song
        }, {
            trace('achievement unlocked successfully!');
        });
    }
}
```