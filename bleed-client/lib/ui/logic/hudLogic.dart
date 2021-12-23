
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/ui/state/tips.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:lemon_engine/game.dart';

import 'showTextBox.dart';

void refreshUI() {
  hud.state.observeMode = false;
  hud.state.showServers = false;
  hud.state.showServers = false;
}

void sendAndCloseTextBox(){
  print("sendAndCloseTextBox()");
  speak(hud.textEditingControllers.speak.text);
  hideTextBox();
}

void toggleEditMode() {
  mode.value = playMode ? Mode.Edit : Mode.Play;
}

void nextTip() {
  hud.state.tipIndex = (hud.state.tipIndex + 1) % tips.length;
  rebuildUI();
}

