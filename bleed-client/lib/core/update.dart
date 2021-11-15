import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/update.dart';
import 'package:lemon_engine/game.dart';

void update() {
  if (playMode) {
    updatePlayMode();
  } else {
    updateEditMode();
  }
}