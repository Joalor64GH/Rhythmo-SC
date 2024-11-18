## Song Audio
First of all, you need your song's audio. You only need an audio file with your music called `music.ogg`. <br>
It should be located in `assets/songs/[song-name]/music.ogg`.

## Song Data
Now, you need your chart. <br>
For your chart, copy this empty template:
```json
{
    "song": "Song Name",
    "notes": [],
    "bpm": 100,
    "timeSignature": [4, 4]
}
```
It should be called `chart.json` and should be located in `assets/songs/[song-name]/chart.json`.

### Charting
To chart your song, go to `PlayState.hx` and then press "7" to go to ChartingState. <br>
Or you can go to your song in `SongSelectState.hx`, and use `SHIFT + ENTER`.

When you're done, simply save the chart by using `Save Chart` or `Save Chart As`. <br> 
Denpending on what you choose, it should save in `assets/songs/[song-name]/chart.json` or `./[song-name].json`.

## Adding your Song to the Song Selection Menu
To add your song to the Song Selection Menu, go to `assets/songs.json`. <br>
Then, to add your song, use this template:
```json
{
    "name": "Song Name",
    "diff": 1
}
```

Now, for your song's cover, it should be in `assets/images/covers/[song-name].png`. <br>
Keep in mind, your song's name should be lowercase and any spaces should be replaced with a dash. <br>
Also, the size of your cover should be a square, preferably `720 by 720`.

## Adding a Script (Optional)
Additionally, you also add in a script that will only run on a specific song. <br>
See [Scripting](./Scripting.md) for more.