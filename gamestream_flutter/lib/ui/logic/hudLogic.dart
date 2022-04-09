
import 'package:gamestream_flutter/ui/state/hud.dart';
import 'package:gamestream_flutter/ui/state/tips.dart';

void refreshUI() {
  hud.state.observeMode = false;
  hud.state.showServers = false;
  hud.state.showServers = false;
}

void nextTip() {
  hud.state.tipIndex = (hud.state.tipIndex + 1) % tips.length;
}

