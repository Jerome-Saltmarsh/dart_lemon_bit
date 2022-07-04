
import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/queries/get_grid_type.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void actionEditorPaint(){
  final type = edit.type.value;
  final z = edit.z.value;
  final row = getMouseRow(z);
  final column = getMouseColumn(z);
  final current = gridGetType(z, row, column);
  if (current == GridNodeType.Boundary) return;
  if (current == type) return;
  sendClientRequestSetBlock(getMouseRow(z), getMouseColumn(z), z, edit.type.value);
}