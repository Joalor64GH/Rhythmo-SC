# How to Add a Custom Song
This will teach you how to add your own song to the game. Really, it's pretty simple.

## Adding your Song
First of all, you need to add your song to the Song Selection Menu. <br>
To do that, go to `assets/songs.json`. Then, to add your song, use this template:
```json
{
    "name": "Song Name",
    "diff": 1
}
```

Now, to add your song's cover, it should be in `assets/images/covers/[song-name].png`. <br>
Keep in mind, your song name should be lowercase and any spaces should be replaced with a dash. <br>
Also, the size of your cover should be a square, preferably `720 by 720`.

## Adding Song Data
For song data, you need the following:
* `assets/songs/[song-name]/chart.json`
* `assets/songs/[song-name]/music.ogg`

For your chart, use this empty template:
```json
{
    "song": "Song Name",
    "notes": [],
    "bpm": 100,
    "timeSignature": [4, 4]
}
```

## Charting
To chart your song, go to `PlayState.hx` and then press "7" to go to ChartingState. <br>
Or you can go to your song in `SongSelectState.hx`, and use `SHIFT + ENTER`.

When you're done, simply save the chart by using `Save Chart` or `Save Chart As`. <br> 
Denpending on what you choose, it should save in `assets/songs/[song-name]/chart.json` or `./[song-name].json`.