
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/watches/selected_scene_name.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void loadSelectedSceneName(){
  final sceneName = selectedSceneName.value;
  if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
  sendClientRequestEditorLoadGame(sceneName);
  actionGameDialogClose();
}