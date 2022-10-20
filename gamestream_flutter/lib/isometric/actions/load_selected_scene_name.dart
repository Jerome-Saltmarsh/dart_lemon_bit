
import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';


void loadSelectedSceneName(){
  final sceneName = EditState.selectedSceneName.value;
  if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
  GameNetwork.sendClientRequestEditorLoadGame(sceneName);
  actionGameDialogClose();
}