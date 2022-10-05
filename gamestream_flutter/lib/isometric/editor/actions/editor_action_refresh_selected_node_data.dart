
import 'package:gamestream_flutter/isometric/edit.dart';

void editorActionRefreshSelectedNodeData(){
  // sendClientRequestSpawnNodeData(
  //   edit.z.value,
  //   edit.row.value,
  //   edit.column.value,
  // );
}

void editorActionClearSelectedNodeData(){
  edit.selectedNodeData.value = null;
}