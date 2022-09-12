
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';

void onChangedSelectedNode(Node node){
   edit.nodeSelectedOrientation.value = node.orientation;
   edit.updateNodeSupports(node.type);
   edit.nodeOrientationVisible.value = NodeType.isOriented(node.type);
}