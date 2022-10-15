
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedSelectedNodeIndex(int index){
   EditState.nodeSelectedOrientation.value = GameState.nodesOrientation[index];
   EditState.nodeSelectedType.value = GameState.nodesType[index];
   EditState.gameObjectSelected.value = false;
   EditState.refreshNodeSelectedIndex();
   EditState.deselectGameObject();
}