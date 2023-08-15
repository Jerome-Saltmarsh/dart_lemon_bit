
import '../common.dart';
import 'isometric_player.dart';

class EditorState {
  final IsometricPlayer player;
  var _selectedMarkIndex = 0;

  EditorState(this.player);

  int get selectedMarkIndex => _selectedMarkIndex;

  set selectedMarkType(int selectedMarkType) {
    final marks = player.game.scene.marks;
    final value = marks[selectedMarkIndex];
    final index = value & 0xFFFF;
    marks[selectedMarkIndex] = index | selectedMarkIndex << 8;
  }


  set selectedMarkIndex(int value){
    if (_selectedMarkIndex == value)
      return;

    _selectedMarkIndex = value;
    player.writeByte(ServerResponse.Editor_Response);
    player.writeByte(EditorResponse.Selected_Mark_Index);
    player.writeUInt16(value);
  }
}