import 'dart:convert';

import 'package:bleed_common/ClientRequest.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_editor_dialog.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_watch/watch.dart';
import 'package:universal_html/html.dart';

final editorDialog = Watch<EditorDialog?>(null, onChanged: onChangedEditorDialog);

enum EditorDialog {
  Scene_Load,
  Scene_Save,
  Canvas_Size,
  Debug,
  Audio_Mixer,
}

void editorLoadScene() async {
    // editorDialog.value = EditorDialog.Scene_Load;

    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    // final file = File(result.files[0], result.files.single.path);
   final contents = result.files[0].bytes;
   if (contents == null) throw Exception("Load Scene Exception: selected file contents are null");
   sendClientRequest(ClientRequest.Editor_Load_Scene, utf8.decode(contents));
}

void actionGameDialogShowSceneSave(){
  editorDialog.value = EditorDialog.Scene_Save;
}

void actionGameDialogClose(){
  editorDialog.value = null;
}
