
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';

import 'action_grid_set_block.dart';

void actionEditorPaintMouse(){
  final z = edit.z.value;
  actionGridSetBlock(z, getMouseRow(z), getMouseColumn(z), edit.type.value);
}