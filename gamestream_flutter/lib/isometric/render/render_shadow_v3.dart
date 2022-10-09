
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';

import 'render_shadow.dart';


double raycastDown(double x, double y){
   return 0.0;
}

void casteShadowDownV3(Vector3 vector3){
  if (vector3.z < nodeHeight) return;
  if (vector3.z >= nodesLengthZ) return;
  final nodeIndex = getGridNodeIndexV3(vector3);
  if (nodeIndex > nodesArea) {
    final nodeBelowIndex = nodeIndex - nodesArea;
    final nodeBelowOrientation = nodesOrientation[nodeBelowIndex];
    if (nodeBelowOrientation == NodeOrientation.Solid){
      final topRemainder = vector3.z % tileHeight;
      renderShadow(vector3.x, vector3.y, vector3.z - topRemainder, scale: topRemainder > 0 ? (topRemainder / tileHeight) * 2 : 2.0);
    }
  }
}