

import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';

void onChangedPaintType(int type){
  edit.paintOrientation.value = NodeType.getDefaultOrientation(type);
}