
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';

void onChangedSelectedNode(Node node){
   edit.updateNodeSupports(node.type);
}