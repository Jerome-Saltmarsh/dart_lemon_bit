
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/player.dart';

import '../factories/generate_node.dart';

void onClickedButtonGridNodeType(int type){
  if (editMode){
    game.setModeEdit();
    edit.column.value = player.indexColumn;
    edit.row.value = player.indexRow;
    edit.z.value = player.indexZ;
    return;
  }
  edit.nodeSelected.value = generateNode(
      edit.z.value,
      edit.row.value,
      edit.column.value,
      type,
      edit.paintOrientation.value,
  );
  edit.paint(value: type);
}

