
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/game_editor.dart';

void onChangedSelectedNodeType(int nodeType){
  GameEditor.nodeOrientationVisible.value = true;
  GameEditor.nodeTypeSpawnSelected.value = nodeType == NodeType.Spawn;
  GameEditor.nodeSupportsSolid.value = NodeType.isOrientationSolid(nodeType);
  GameEditor.nodeSupportsCorner.value = NodeType.isCorner(nodeType);
  GameEditor.nodeSupportsHalf.value = NodeType.isHalf(nodeType);
  GameEditor.nodeSupportsSlopeCornerInner.value = NodeType.isSlopeCornerInner(nodeType);
  GameEditor.nodeSupportsSlopeCornerOuter.value = NodeType.isSlopeCornerOuter(nodeType);
  GameEditor.nodeSupportsSlopeSymmetric.value = NodeType.isSlopeSymmetric(nodeType);
}
