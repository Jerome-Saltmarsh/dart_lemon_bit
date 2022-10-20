
import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/game_editor.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';


void loadSelectedSceneName(){
  final sceneName = GameEditor.selectedSceneName.value;
  if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
  GameNetwork.sendClientRequestEditorLoadGame(sceneName);
  actionGameDialogClose();
}