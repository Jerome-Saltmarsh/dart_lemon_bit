
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void onEditorRowChanged(int row){
  edit.type.value = grid[edit.z.value][row][edit.column.value];
}