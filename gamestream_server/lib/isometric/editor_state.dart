
import '../common.dart';
import 'isometric_game.dart';
import 'isometric_player.dart';
import 'scene.dart';

class EditorState {

  final IsometricPlayer player;
  var _selectedMarkListIndex = 0;

  EditorState(this.player);

  IsometricGame get game => player.game;

  Scene get scene => game.scene;

  int get selectedMarkListIndex => _selectedMarkListIndex;

  int get selectedMarkNodeIndex => scene.marks[_selectedMarkListIndex] & 0xFFFF;

  int get selectedMarkType => scene.marks[_selectedMarkListIndex] >> 16 & 0xFF;

  set selectedMarkType(int markType) {
    scene.marks[_selectedMarkListIndex] = selectedMarkNodeIndex | markType << 16;
  }

  set selectedMarkListIndex(int value){
    if (_selectedMarkListIndex == value)
      return;

    if (value >= scene.marks.length){
      player.writeGameError(GameError.Invalid_Mark_Stack_Index);
      return;
    }

    _selectedMarkListIndex = value;
    player.writeByte(ServerResponse.Editor_Response);
    player.writeByte(EditorResponse.Selected_Mark_List_Index);
    player.writeUInt16(value);
  }

  void setMarkType(int markType) {
    if (_selectedMarkListIndex < 0){
      player.writeGameError(GameError.Selected_Mark_Index_Not_Set);
      return;
    }
    if (_selectedMarkListIndex >= scene.marks.length){
      player.writeGameError(GameError.Invalid_Mark_Stack_Index);
      return;
    }
    scene.marks[_selectedMarkListIndex] = selectedMarkNodeIndex | (markType << 16);
    game.notifySceneMarksChanged();
  }

  void addMark(int nodeIndex) {
    scene.marks.add(nodeIndex);
    selectedMarkListIndex = scene.marks.length - 1;
    game.notifySceneMarksChanged();
  }

  void deleteMark(int index) {
    final game = player.game;

    if (index >= scene.marks.length)
      return;

    scene.marks.removeAt(index);
    deselectMarkListIndex();
    game.notifySceneMarksChanged();
  }

  void deselectMarkListIndex() {
    // selectedMarkListIndex = -1;
  }
}