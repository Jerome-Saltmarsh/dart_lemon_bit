
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';

void onChangedSelectedNodeIndex(int index){
   edit.nodeSelectedOrientation.value = nodesOrientation[index];
   edit.nodeSelectedType.value = nodesType[index];
   edit.gameObjectSelected.value = false;
   edit.refreshNodeSelectedIndex();
   edit.deselectGameObject();
}