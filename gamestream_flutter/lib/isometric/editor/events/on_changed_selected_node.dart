
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';

void onChangedSelectedNodeIndex(int index){
   edit.nodeSelectedOrientation.value = gridNodeOrientations[index];
   edit.nodeSelectedType.value = gridNodeTypes[index];
   edit.gameObjectSelected.value = false;
   edit.refreshNodeSelectedIndex();
   edit.deselectGameObject();
}