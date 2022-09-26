
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    game.textFieldMessage.requestFocus();
    return;
  }
  sendRequestSpeak(game.textEditingControllerMessage.text);
  game.textFieldMessage.unfocus();
  game.textEditingControllerMessage.text = "";
}