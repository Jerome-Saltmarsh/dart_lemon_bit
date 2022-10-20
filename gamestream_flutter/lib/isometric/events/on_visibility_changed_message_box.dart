
import 'package:gamestream_flutter/game_library.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    GameUI.textFieldMessage.requestFocus();
    return;
  }
  GameNetwork.sendRequestSpeak(GameUI.textEditingControllerMessage.text);
  GameUI.textFieldMessage.unfocus();
  GameUI.textEditingControllerMessage.text = "";
}