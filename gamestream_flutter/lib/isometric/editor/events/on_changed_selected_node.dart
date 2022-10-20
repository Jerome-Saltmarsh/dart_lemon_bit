
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_editor.dart';

void onChangedSelectedNodeIndex(int index){
   GameEditor.nodeSelectedOrientation.value = GameState.nodesOrientation[index];
   GameEditor.nodeSelectedType.value = GameState.nodesType[index];
   GameEditor.gameObjectSelected.value = false;
   GameEditor.refreshNodeSelectedIndex();
   GameEditor.deselectGameObject();
}