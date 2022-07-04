
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void actionPaint(){
  final z = edit.z.value;
  sendClientRequestSetBlock(getMouseRow(edit.z.value), getMouseColumn(edit.z.value), edit.z.value, edit.type.value);
}