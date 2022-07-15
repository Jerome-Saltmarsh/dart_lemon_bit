
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void onEditorZChanged(int z){
  edit.type.value = grid[z][edit.row.value][edit.column.value];
}