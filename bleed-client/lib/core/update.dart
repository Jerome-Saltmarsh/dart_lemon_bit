import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/tutorials.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/update.dart';
import 'package:lemon_engine/game.dart';

void update() {
  
  if (state.lobby != null) {
    sendRequestUpdateLobby();
    return;
  }

  if (rightClickDown){
    inputRequest.sprint = true;
  }

  if (!tutorialsFinished && tutorial.getFinished()) {
    tutorialNext();
    sharedPreferences.setInt('tutorialIndex', tutorialIndex);
  }

  if (playMode) {
    updatePlayMode();
    updateMenuVisible();
  } else {
    updateEditMode();
  }
}

void updateMenuVisible() {
  hud.state.menuVisible.value = mouseAvailable && mouseX > screenWidth - 300 && mouseY < 200;
}