
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

import '../isometric/play_mode.dart';

void onMouseDrag(){
  if (playModeEdit) {
    switch(editTool.value){
      case EditTool.Paint:
        sendClientRequestSetBlock(getMouseRow(edit.z.value), getMouseColumn(edit.z.value), edit.z.value, edit.type.value);
        break;
    }
  }
}