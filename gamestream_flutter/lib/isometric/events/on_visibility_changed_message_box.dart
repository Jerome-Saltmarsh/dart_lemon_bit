
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/library.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    GameUI.textFieldMessage.requestFocus();
    return;
  }
  gsEngine.network.sendRequestSpeak(GameUI.textEditingControllerMessage.text);
  GameUI.textFieldMessage.unfocus();
  GameUI.textEditingControllerMessage.text = "";
}