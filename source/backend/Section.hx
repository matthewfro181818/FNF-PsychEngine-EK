package backend;

typedef SwagSection =
{
	var sectionNotesArrayDynamic;
	var sectionBeatsFloat;
	var mustHitSectionBool;
	var gfSectionBool;
	var bpmFloat;
	var changeBPMBool;
	var altAnimBool;
}

class Section
{
	public var sectionNotesArrayDynamic = [];

	public var sectionBeatsFloat = 4;
	public var gfSectionBool = false;
	public var mustHitSectionBool = true;

	public function new(sectionBeatsFloat = 4)
	{
		this.sectionBeats = sectionBeats;
		trace('test created section ' + sectionBeats);
	}
}