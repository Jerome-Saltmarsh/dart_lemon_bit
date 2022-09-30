
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedSelectedNodeType(int nodeType){
  edit.nodeOrientationVisible.value = NodeType.isOriented(nodeType);
  edit.nodeTypeSpawnSelected.value = nodeType == NodeType.Spawn;
}