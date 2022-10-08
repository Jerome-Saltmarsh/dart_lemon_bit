import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';

void rainOff() {
  for (var i = 0; i < nodesTotal; i++) {
    if (!NodeType.isRain(nodesType[i])) continue;
    nodesType[i] = NodeType.Empty;
    nodesOrientation[i] = NodeOrientation.None;
  }
}
