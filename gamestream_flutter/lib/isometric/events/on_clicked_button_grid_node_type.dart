
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';

import '../factories/generate_grid_node.dart';
import '../play_mode.dart';

void onClickedButtonGridNodeType(int type){
  if (modeIsPlay){
    setPlayModeEdit();
    edit.column.value = player.indexColumn;
    edit.row.value = player.indexRow;
    edit.z.value = player.indexZ;
    return;
  }
  edit.selected.value = generateNode(edit.z.value, edit.row.value, edit.column.value, type);
  if (editTool.value == EditTool.Select){
    edit.paint(value: type);
  }
}

