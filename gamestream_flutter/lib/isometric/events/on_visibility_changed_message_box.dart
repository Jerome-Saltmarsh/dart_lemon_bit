
import 'package:gamestream_flutter/library.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    GameUI.textFieldMessage.requestFocus();
    return;
  }
  gamestream.network.sendRequestSpeak(GameUI.textEditingControllerMessage.text);
  GameUI.textFieldMessage.unfocus();
  GameUI.textEditingControllerMessage.text = "";
}