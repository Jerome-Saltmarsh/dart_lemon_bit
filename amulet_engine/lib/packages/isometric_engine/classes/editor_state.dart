
import '../isometric_engine.dart';

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
    if (_selectedMarkListIndex == value) {
      return;
    }

    if (value >= scene.marks.length){
      player.writeGameError(GameError.Invalid_Mark_Stack_Index);
      return;
    }

    _selectedMarkListIndex = value;
    player.writeByte(NetworkResponse.Editor);
    player.writeByte(NetworkResponseEditor.Selected_Mark_List_Index);
    player.writeInt16(value);
  }

  void setSelectedMarkType(int markType) {
    if (_selectedMarkListIndex == -1) {
      throw Exception('nothing selected');
    }
    final markValue = scene.setMarkType(listIndex: _selectedMarkListIndex, markType: markType);
    game.sortMarksAndDispatch();
    selectedMarkListIndex = scene.marks.indexOf(markValue);
  }

  void setSelectedMarkSubType(int markSubType) {
    if (_selectedMarkListIndex == -1) {
      throw Exception('nothing selected');
    }
    final markValue = scene.setMarkType(
        listIndex: _selectedMarkListIndex,
        markType: selectedMarkType,
        markSubType: markSubType,
    );
    game.sortMarksAndDispatch();
    selectedMarkListIndex = scene.marks.indexOf(markValue);
  }

  void addMark(int markValue) {
    scene.marks.add(markValue);
    game.sortMarksAndDispatch();
    selectedMarkListIndex = scene.marks.indexOf(markValue);
  }

  void deleteMark() {
    final game = player.game;

    final listIndex = player.editor.selectedMarkListIndex;

    if (listIndex < 0 || listIndex >= scene.marks.length) {
      return;
    }

    scene.marks.removeAt(listIndex);
    deselectMarkListIndex();
    game.sortMarksAndDispatch();
  }

  void deselectMarkListIndex() {
    selectedMarkListIndex = -1;
  }
}