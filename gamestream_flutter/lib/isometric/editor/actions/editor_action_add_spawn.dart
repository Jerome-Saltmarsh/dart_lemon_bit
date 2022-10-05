
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void editorActionAddGameObject(int type){
  sendClientRequestAddGameObject(
      z: edit.z,
      row: edit.row,
      column: edit.column,
      type: type,
  );
}
