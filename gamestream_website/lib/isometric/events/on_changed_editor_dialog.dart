
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onChangedEditorDialog(EditorDialog? value){
  if (value == EditorDialog.Scene_Load){
    sendClientRequestCustomGameNames();
  }
}