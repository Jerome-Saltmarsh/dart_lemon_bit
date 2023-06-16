
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

void onVisibilityChangedMessageBox(bool visible){
  if (visible) {
    GameIsometricUI.textFieldMessage.requestFocus();
    return;
  }
  GameIsometricUI.textFieldMessage.unfocus();
  GameIsometricUI.textEditingControllerMessage.text = "";
}