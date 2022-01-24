import 'package:bleed_client/modules/editor/editor.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/watches/mode.dart';

void update() {
  if (playMode) {
    updatePlayMode();
  } else {
    editor.update();
  }
}