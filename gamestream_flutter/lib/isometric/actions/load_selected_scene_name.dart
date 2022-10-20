
import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/watches/selected_scene_name.dart';

void loadSelectedSceneName(){
  final sceneName = selectedSceneName.value;
  if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
  GameNetwork.sendClientRequestEditorLoadGame(sceneName);
  actionGameDialogClose();
}