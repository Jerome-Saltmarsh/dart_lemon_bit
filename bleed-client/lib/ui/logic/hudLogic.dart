
import 'package:bleed_client/editor/functions/registerEditorKeyboardListener.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/removeGeneratedEnvironmentObjects.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/network/streams/onConnectError.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/ui/compose/dialogs.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/ui/state/tips.dart';
import 'package:lemon_engine/game.dart';
import 'package:neuro/instance.dart';

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

clearUI() {
  hud.stateSetters.score = null;
}

void rebuildScore() {
  if (hud.stateSetters.score == null) return;
  hud.stateSetters.score(_doNothing);
}

void _doNothing() {}

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

void closeMainMenuDialog() {
  if (contextMainMenuDialog == null) return;
  pop(contextMainMenuDialog);
}

void nextTip() {
  tipIndex = (tipIndex + 1) % tips.length;
  rebuildUI();
}

