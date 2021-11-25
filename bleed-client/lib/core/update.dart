import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/watches/mode.dart';

void update() {
  if (playMode) {
    updatePlayMode();
  } else {
    updateEditMode();
  }
}