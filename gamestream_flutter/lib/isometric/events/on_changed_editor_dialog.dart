
import 'package:gamestream_flutter/library.dart';

void onChangedEditorDialog(EditorDialog? value){
  if (value == EditorDialog.Scene_Load){
    GameNetwork.sendClientRequestCustomGameNames();
  }
}