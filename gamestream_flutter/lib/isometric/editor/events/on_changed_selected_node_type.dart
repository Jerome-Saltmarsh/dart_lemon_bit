
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedSelectedNodeType(int nodeType){
  edit.nodeOrientationVisible.value = true;
  edit.nodeTypeSpawnSelected.value = nodeType == NodeType.Spawn;
  edit.nodeSupportsSolid.value = NodeType.isOrientationSolid(nodeType);
  edit.nodeSupportsCorner.value = NodeType.isCorner(nodeType);
  edit.nodeSupportsHalf.value = NodeType.isHalf(nodeType);
  edit.nodeSupportsSlopeCornerInner.value = NodeType.isSlopeCornerInner(nodeType);
  edit.nodeSupportsSlopeCornerOuter.value = NodeType.isSlopeCornerOuter(nodeType);
  edit.nodeSupportsSlopeSymmetric.value = NodeType.isSlopeSymmetric(nodeType);
}
