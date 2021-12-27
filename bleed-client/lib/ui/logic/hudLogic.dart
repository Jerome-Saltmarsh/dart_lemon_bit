
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/ui/state/tips.dart';
import 'package:bleed_client/watches/mode.dart';

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

void nextTip() {
  hud.state.tipIndex = (hud.state.tipIndex + 1) % tips.length;
}

