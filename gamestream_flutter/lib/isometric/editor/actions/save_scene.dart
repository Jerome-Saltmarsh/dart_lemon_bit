
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void requestSaveScene() {
  sendClientRequest(ClientRequest.Save_Scene);
}