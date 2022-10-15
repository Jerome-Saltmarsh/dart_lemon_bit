
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedSelectedNodeIndex(int index){
   edit.nodeSelectedOrientation.value = GameState.nodesOrientation[index];
   edit.nodeSelectedType.value = GameState.nodesType[index];
   edit.gameObjectSelected.value = false;
   edit.refreshNodeSelectedIndex();
   edit.deselectGameObject();
}