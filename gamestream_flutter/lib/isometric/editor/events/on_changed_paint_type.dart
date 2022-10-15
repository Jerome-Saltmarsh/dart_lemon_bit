

import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void onChangedPaintType(int type) {
  if (!NodeType.supportsOrientation(type, EditState.paintOrientation.value))
    return EditState.setPaintOrientationNone();
  if (NodeType.supportsOrientation(type, EditState.paintOrientation.value)) return;
  EditState.assignDefaultNodeOrientation(type);
}