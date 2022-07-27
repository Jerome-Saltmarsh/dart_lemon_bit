
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';

import '../play_mode.dart';

void onClickedButtonGridNodeType(int type){
  if (playModePlay){
    setPlayModeEdit();
    edit.column.value = player.indexColumn;
    edit.row.value = player.indexRow;
    edit.z.value = player.indexZ;
    return;
  }
  edit.type.value = type;
  if (editTool.value == EditTool.Select){
    edit.paint(type);
  }
}