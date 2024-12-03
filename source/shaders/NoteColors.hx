package shaders;

class NoteColors {
	public static var noteColors:Array<Array<Int>> = SaveData.settings.notesRGB;

	public static final defaultColors:Array<Array<Int>> = [[221, 0, 255], [0, 128, 255], [0, 215, 54], [255, 0, 106]];

	public static function setNoteColor(note:Int, color:Array<Int>):Void {
		noteColors[note] = color;
		SaveData.settings.notesRGB[note] = color;
		SaveData.saveSettings();
	}

	public static function getNoteColor(note:Int):Array<Int> {
		return noteColors[note];
	}
}