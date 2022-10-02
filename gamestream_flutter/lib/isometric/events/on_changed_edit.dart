

import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';

void onChangedEdit(bool value){
  if (value){
     edit.z.value = playerZ;
     edit.row.value = playerRow;
     edit.column.value = playerColumn;
  }
}