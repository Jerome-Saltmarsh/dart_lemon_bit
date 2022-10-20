
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_library.dart';

void requestSaveScene() {
  GameNetwork.sendClientRequest(ClientRequest.Save_Scene);
}