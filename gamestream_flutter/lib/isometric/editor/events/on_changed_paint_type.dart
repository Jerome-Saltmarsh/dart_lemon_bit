

import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/game_editor.dart';

void onChangedPaintType(int type) {
  if (!NodeType.supportsOrientation(type, GameEditor.paintOrientation.value))
    return GameEditor.setPaintOrientationNone();
  if (NodeType.supportsOrientation(type, GameEditor.paintOrientation.value)) return;
  GameEditor.assignDefaultNodeOrientation(type);
}