import 'package:gamestream_flutter/isometric/events/on_changed_editor_dialog.dart';
import 'package:lemon_watch/watch.dart';

final editorDialog = Watch<EditorDialog?>(null, onChanged: onChangedEditorDialog);

enum EditorDialog {
  Scene_Load,
  Scene_Save,
  Canvas_Size,
  Debug,
  Audio_Mixer,
}

void actionGameDialogShowSceneLoad(){
    editorDialog.value = EditorDialog.Scene_Load;
}

void actionGameDialogShowSceneSave(){
  editorDialog.value = EditorDialog.Scene_Save;
}

void actionGameDialogClose(){
  editorDialog.value = null;
}
