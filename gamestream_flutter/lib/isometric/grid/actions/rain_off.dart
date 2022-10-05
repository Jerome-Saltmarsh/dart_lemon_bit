import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';

void rainOff() {
  for (var i = 0; i < gridNodeTotal; i++) {
    if (!NodeType.isRain(gridNodeTypes[i])) continue;
    gridNodeTypes[i] = NodeType.Empty;
    gridNodeOrientations[i] = NodeOrientation.None;
  }
}
