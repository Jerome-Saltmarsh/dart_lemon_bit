
import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';

void onChangedEditorDialog(EditorDialog? value){
  if (value == EditorDialog.Scene_Load){
    GameNetwork.sendClientRequestCustomGameNames();
  }
}