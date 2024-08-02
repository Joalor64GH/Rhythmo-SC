# How to Add a Custom Song
This will teach you how to add your own song to the game. Really, it's pretty simple.

## Adding your Song
First of all, you need to add your song to the Song Selection Menu. <br>
To do that, go to `assets/data/songList.json`. Then, to add your song, use this template:
```json
{
    "name": "Song Name",
    "diff": "1/5"
}
```

Now, to add your song's cover, it should be in `assets/images/selector/covers/[song-name].png`. <br>
Keep in mind, your song name should be lowercase and any spaces should be replaced with a dash.

## Adding Song Data
For song data, you need the following:
* `assets/songs/[song-name]/chart.json` (Required)
* `assets/songs/[song-name]/music.ogg` (Required)
* `assets/songs/[song-name]/script.hxs` (Optional)