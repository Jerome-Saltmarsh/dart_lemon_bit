enum ToolTab {
  Tiles,
  Objects,
  All,
  Units,
  Misc
}

enum EditTool {
  Tile,
  EnvironmentObject
}

enum EditorDialog {
  None,
  Load,
  Save,
  Loading_Map
}

enum TimeSpeed {
  Stopped,
  Slow,
  Normal,
  Fast,
}

final List<TimeSpeed> timeSpeeds = TimeSpeed.values;


enum TeamType {
  Teams,
  Solo,
}