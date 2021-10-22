
import 'package:bleed_client/ui/state/hudState.dart';

void showTextBox(){
  hud.state.textBoxVisible = true;
  hud.focusNodes.textFieldMessage.requestFocus();
  _rebuildTextBox();
}

void hideTextBox(){
  hud.focusNodes.textFieldMessage.unfocus();
  hud.state.textBoxVisible = false;
  hud.textEditingControllers.speak.text = "";
  _rebuildTextBox();
}

void _rebuildTextBox(){
  hud.stateSetters.playerMessage((){});
}