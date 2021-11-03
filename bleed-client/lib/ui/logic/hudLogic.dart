
import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/engine/functions/refreshPage.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/removeGeneratedEnvironmentObjects.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/network/streams/onConnectError.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/tutorials.dart';
import 'package:bleed_client/ui/compose/dialogs.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/ui/state/tips.dart';
import 'package:neuro/instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'showTextBox.dart';


void initUI() {
  onConnectError.stream.listen((event) {
    showDialogConnectFailed();
  });

  respondTo((GameJoined gameStarted) async {
    closeMainMenuDialog();
  });

  on((LobbyJoined _) async {
    closeMainMenuDialog();
    rebuildUI();
  });

  // TODO Refactor
  SharedPreferences.getInstance().then((instance) {
    //@ on sharedPreferences loaded
    sharedPreferences = instance;
    dispatch(instance);
    if (sharedPreferences.containsKey("tutorialIndex")) {
      tutorialIndex = sharedPreferences.getInt('tutorialIndex');
    }
    settings.audioMuted = sharedPreferences.containsKey('audioMuted') &&
        sharedPreferences.getBool('audioMuted');

    if (sharedPreferences.containsKey('server')) {
      Server server = servers[sharedPreferences.getInt('server')];
      connectServer(server);
    }

    if (sharedPreferences.containsKey('last-refresh')) {
      DateTime lastRefresh =
      DateTime.parse(sharedPreferences.getString('last-refresh'));
      DateTime now = DateTime.now();
      if (now.difference(lastRefresh).inHours > 1) {
        sharedPreferences.setString(
            'last-refresh', DateTime.now().toIso8601String());
        refreshPage();
      }
    } else {
      sharedPreferences.setString(
          'last-refresh', DateTime.now().toIso8601String());
    }
  });
}

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

redrawBottomLeft() {
  if (hud.stateSetters.bottomLeft == null) return;
  hud.stateSetters.bottomLeft(_doNothing);
}

clearUI() {
  hud.stateSetters.bottomLeft = null;
  hud.stateSetters.score = null;
}

void rebuildScore() {
  if (hud.stateSetters.score == null) return;
  hud.stateSetters.score(_doNothing);
}

void _doNothing() {}

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}

void toggleEditMode() {
  if (playMode) {
    print("mode = Mode.Edit");
    mode = Mode.Edit;
    removeGeneratedEnvironmentObjects();
    registerEditorKeyboardListener();
    deregisterPlayKeyboardHandler();
  } else {
    print("mode = Mode.Play");
    mode = Mode.Play;
  }

  rebuildUI();
  redrawCanvas();
}

void toggleShowScore() {
  hud.state.showScore = !hud.state.showScore;
  rebuildUI();
}

void rebuildNpcMessage() {
  if (hud.stateSetters.npcMessage == null) return;
  hud.stateSetters.npcMessage(_doNothing);
}

void closeMainMenuDialog() {
  if (contextMainMenuDialog == null) return;
  pop(contextMainMenuDialog);
}

void nextTip() {
  tipIndex = (tipIndex + 1) % tips.length;
  rebuildUI();
}

String getMessage() {
  if (player.health == 0) return null;

  if (player.health < player.maxHealth * 0.25) {
    if (player.meds > 0) {
      return "Low Health: Press H to heal";
    }
  }
  if (player.equippedRounds == 0) {
    if (player.equippedClips == 0) {
      return 'Empty: Press 1, 2, 3 to change weapons';
    } else {
      return 'Press R to reload';
    }
  }

  if (player.equippedRounds <= 2) {
    return "Low Ammo";
  }

  return null;
}
