

import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedPaintType(int type) {
  if (!NodeType.supportsOrientation(type, edit.paintOrientation.value))
    return edit.setPaintOrientationNone();
  if (NodeType.supportsOrientation(type, edit.paintOrientation.value)) return;
  edit.assignDefaultNodeOrientation(type);
}