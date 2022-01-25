import 'package:bleed_client/modules.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/watches/mode.dart';

void update() {
  core.state.timeline.update();
  if (playMode) {
    updatePlayMode();
  } else {
    editor.update();
  }
}