
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    GameIsometricUI.textFieldMessage.requestFocus();
    return;
  }
  GameIsometricUI.textFieldMessage.unfocus();
  GameIsometricUI.textEditingControllerMessage.text = "";
}