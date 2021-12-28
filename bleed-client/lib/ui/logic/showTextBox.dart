
import 'package:bleed_client/ui/state/hud.dart';

void showTextBox(){
  hud.state.textBoxVisible.value = true;
  hud.focusNodes.textFieldMessage.requestFocus();
}

void hideTextBox(){
  hud.focusNodes.textFieldMessage.unfocus();
  hud.state.textBoxVisible.value = false;
  hud.textEditingControllers.speak.text = "";
}
