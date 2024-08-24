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
* `assets/songs/[song-name]/chart.json` (Required)
* `assets/songs/[song-name]/music.ogg` (Required)
* `assets/songs/[song-name]/script.hxs` (Optional)

## Charting
Before you actually chart your song, you need `chart.json`. <br>
Use this template:
```json
{
    "song": "Song Name",
    "notes": [],
    "bpm": 100,
    "timeSignature": [4, 4]
}
```

Now, to chart your song, go to PlayState and then press "7" to go to ChartingState. <br>
When you're done, simply save the chart. It should save in `assets/songs/[song-name]/chart.json`.

Also, you'll have to manually change the BPM and time signature beforehand.