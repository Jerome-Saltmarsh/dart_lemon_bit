
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedSelectedNodeType(int nodeType){
  EditState.nodeOrientationVisible.value = true;
  EditState.nodeTypeSpawnSelected.value = nodeType == NodeType.Spawn;
  EditState.nodeSupportsSolid.value = NodeType.isOrientationSolid(nodeType);
  EditState.nodeSupportsCorner.value = NodeType.isCorner(nodeType);
  EditState.nodeSupportsHalf.value = NodeType.isHalf(nodeType);
  EditState.nodeSupportsSlopeCornerInner.value = NodeType.isSlopeCornerInner(nodeType);
  EditState.nodeSupportsSlopeCornerOuter.value = NodeType.isSlopeCornerOuter(nodeType);
  EditState.nodeSupportsSlopeSymmetric.value = NodeType.isSlopeSymmetric(nodeType);
}
