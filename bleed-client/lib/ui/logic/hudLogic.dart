
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/state/tips.dart';

import 'showTextBox.dart';

void refreshUI() {
  hud.state.observeMode = false;
  hud.state.showServers = false;
  hud.state.showServers = false;
}

void nextTip() {
  hud.state.tipIndex = (hud.state.tipIndex + 1) % tips.length;
}

