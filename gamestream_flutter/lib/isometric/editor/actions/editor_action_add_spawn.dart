
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void editorActionAddGameObject(int type){
  sendClientRequestAddGameObject(
      z: edit.z.value,
      row: edit.row.value,
      column: edit.column.value,
      type: type,
  );
}
