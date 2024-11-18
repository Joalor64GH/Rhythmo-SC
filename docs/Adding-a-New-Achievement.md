## Achievement Data
Firstly, you need a json file for your achievement. Copy this template:
```json
{
    "name": "Name",
    "desc": "Description",
    "hint": "Hint"
}
```

It should be located in `assets/achievements/[achievement-name].json`. <br>
Then, for your achievement to actually be loaded, navigate to `assets/achievements/achList.txt` and add it there.

Now, you simply need an icon for your achievement. Your icon should be in `assets/images/achievements/[name].png`. <br>
I recommend that the image's size should be a square, preferably `150 x 150`.

## Unlocking your Achievement
To actually be able to unlock your custom achievement, you can do it through [scripting](https://github.com/Joalor64GH/Rhythmo-SC/wiki/Scripting). <br>
Example:
```hx
import('states.PlayState');
import('backend.Achievements');

var condition:Bool = false;

function update(elapsed:Float) {
    if (PlayState.instance.score >= 1000000)
        condition = true;
}

function endSong() {
    if (condition) {
        Achievements.unlock('road_to_a_million', {
            date: Date.now(),
            song: PlayState.song.song
        }, {
            trace('achievement unlocked successfully!');
        });
    }
}
```