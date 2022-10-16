
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedSelectedNodeIndex(int index){
   EditState.nodeSelectedOrientation.value = Game.nodesOrientation[index];
   EditState.nodeSelectedType.value = Game.nodesType[index];
   EditState.gameObjectSelected.value = false;
   EditState.refreshNodeSelectedIndex();
   EditState.deselectGameObject();
}