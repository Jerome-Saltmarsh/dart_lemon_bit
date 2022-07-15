
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void onEditorColumnChanged(int value){
  edit.type.value = grid[edit.z.value][edit.row.value][value];
}