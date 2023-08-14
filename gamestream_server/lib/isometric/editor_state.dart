
import 'package:gamestream_server/core.dart';

import '../common.dart';

class EditorState {
  final Player player;
  var _selectedMarkIndex = 0;

  EditorState(this.player);

  int get selectedMarkIndex => _selectedMarkIndex;

  set selectedMarkIndex(int value){
    if (_selectedMarkIndex == value)
      return;

    _selectedMarkIndex = value;
    player.writeByte(ServerResponse.Editor_Response);
    player.writeByte(EditorResponse.Selected_Mark_Index);
    player.writeUInt16(value);
  }
}