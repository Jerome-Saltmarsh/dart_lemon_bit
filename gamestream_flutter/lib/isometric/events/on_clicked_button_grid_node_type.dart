
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/player.dart';

import '../factories/generate_node.dart';
import '../play_mode.dart';

void onClickedButtonGridNodeType(int type){
  if (modeIsPlay){
    setPlayModeEdit();
    edit.column.value = player.indexColumn;
    edit.row.value = player.indexRow;
    edit.z.value = player.indexZ;
    return;
  }
  edit.selectedNode.value = generateNode(
      edit.z.value,
      edit.row.value,
      edit.column.value,
      type,
      edit.paintOrientation.value,
  );
  edit.paint(value: type);
}

