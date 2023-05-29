
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    GameIsometricUI.textFieldMessage.requestFocus();
    return;
  }
  gamestream.network.sendRequestSpeak(GameIsometricUI.textEditingControllerMessage.text);
  GameIsometricUI.textFieldMessage.unfocus();
  GameIsometricUI.textEditingControllerMessage.text = "";
}