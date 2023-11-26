
import 'package:gamestream_flutter/isometric/watches/player_entered_scene_name.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void actionSaveScene(){
  final sceneName = playerEnteredSceneName.value;
   if (sceneName == null) throw Exception("entered scene name is null");
   if (sceneName.isEmpty) throw Exception("entered scene name is empty");
   sendClientRequestEditorSetSceneName(sceneName);
}