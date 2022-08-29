
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric_web/download_file.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void editorSaveScene() {
  // final sceneName = playerEnteredSceneName.value;
  //  if (sceneName == null) throw Exception("entered scene name is null");
  //  if (sceneName.isEmpty) throw Exception("entered scene name is empty");
  //  sendClientRequestEditorSetSceneName(sceneName);
  sendClientRequest(ClientRequest.Save_Scene);
}