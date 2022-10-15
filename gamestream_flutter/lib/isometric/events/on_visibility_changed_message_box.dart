
import 'package:gamestream_flutter/game_ui.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    GameUI.textFieldMessage.requestFocus();
    return;
  }
  sendRequestSpeak(GameUI.textEditingControllerMessage.text);
  GameUI.textFieldMessage.unfocus();
  GameUI.textEditingControllerMessage.text = "";
}