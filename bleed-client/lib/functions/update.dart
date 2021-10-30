import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/tutorials.dart';
import 'package:bleed_client/update.dart';

bool _showMenuOptions = false;

void update() {
  DateTime now = DateTime.now();
  refreshDuration = now.difference(lastRefresh);
  lastRefresh = DateTime.now();

  if (state.lobby != null) {
    sendRequestUpdateLobby();
    return;
  }

  // TODO Does not belong here
  _showHideTopLeftMenuOptions();

  if (!tutorialsFinished && tutorial.getFinished()) {
    tutorialNext();
    sharedPreferences.setInt('tutorialIndex', tutorialIndex);
  }

  if (playMode) {
    updatePlayMode();
  } else {
    updateEditMode();
  }
}

void _showHideTopLeftMenuOptions() {
  if (!mouseAvailable) return;
  if (mouseX < 300 && mouseY < 300) {
    if (!_showMenuOptions) {
      _showMenuOptions = true;
      rebuildUI();
    }
  } else {
    if (_showMenuOptions) {
      _showMenuOptions = false;
      rebuildUI();
    }
  }
}