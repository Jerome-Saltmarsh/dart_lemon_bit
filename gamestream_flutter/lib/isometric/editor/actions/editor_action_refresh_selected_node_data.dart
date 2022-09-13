
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void editorActionRefreshSelectedNodeData(){
  sendClientRequestSpawnNodeData(
    edit.z.value,
    edit.row.value,
    edit.column.value,
  );
}

void editorActionClearSelectedNodeData(){
  edit.selectedNodeData.value = null;
}