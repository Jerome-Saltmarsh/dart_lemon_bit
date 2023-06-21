
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_editor_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/stack_fullscreen.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_isometric_ui.dart';

class GameIsometric extends Game {

  final Isometric isometric;

  GameIsometric({required this.isometric}) {
    isometric.camera.chaseTarget = isometric.player.position;
  }

  IsometricPlayer get player => isometric.player;

  @override
  void drawCanvas(Canvas canvas, Size size) {
    isometric.drawCanvas(canvas, size);
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    isometric.renderer.renderForeground(canvas, size);
  }

  @override
  void update() {
    isometric.update();
  }

  void sendIsometricClientRequest([dynamic message]) {
    gamestream.network.sendClientRequest(ClientRequest.Isometric, message);
  }

  @override
  void onActivated() {
    gamestream.isometric.particles.clearParticles();
    isometric.clientState.control_visible_player_weapons.value = true;
    isometric.clientState.control_visible_scoreboard.value = true;
    isometric.clientState.control_visible_player_power.value = true;
    isometric.clientState.window_visible_player_creation.value = false;
    isometric.clientState.control_visible_respawn_timer.value = false;
    isometric.clientState.control_visible_player_weapons.value = false;
    isometric.clientState.window_visible_player_creation.value = false;
    isometric.clientState.control_visible_respawn_timer.value = false;
    isometric.ui.menuOpen.setFalse();

    gamestream.audio.musicStop();
    engine.onMouseMoved = gamestream.io.touchController.onMouseMoved;

    if (!engine.isLocalHost) {
      engine.fullScreenEnter();
    }
  }

  Widget customBuildUI(BuildContext context){
    return const SizedBox();
  }

  List<Widget> buildMenuItems(){
    return [];
  }

  @override
  Widget buildUI(BuildContext context) => StackFullscreen(children: [
      buildWatchBool(
          gamestream.isometric.clientState.triggerAlarmNoMessageReceivedFromServer,
          GameIsometricUI.buildDialogFramesSinceUpdate,
      ),
      WatchBuilder(isometric.clientState.edit, (edit) =>
        edit ? gamestream.isometric.editor.buildEditor() : customBuildUI(context)),
      buildWatchBool(isometric.clientState.debugMode, gamestream.isometric.ui.buildStackDebug),
      buildWatchBool(isometric.clientState.window_visible_light_settings,
          GameIsometricUI.buildWindowLightSettings),
      Positioned(top: 16, right: 16, child: GameIsometricUI.buildMainMenu(children: buildMenuItems())),


    ]);

  @override
  void onLeftClicked() {
    if (gamestream.io.inputModeTouch){
      gamestream.io.touchController.onClick();
    }
    if (isometric.clientState.edit.value) {
      isometric.editor.onMouseLeftClicked();
    }
  }

  @override
  void onKeyPressed(int key) {

    if (key == KeyCode.Tab) {
      gamestream.isometric.clientState.edit.value = !gamestream.isometric.clientState.edit.value;
      return;
    }

    if (isometric.clientState.editMode){
      isometric.editor.onKeyPressedModeEdit(key);
    } else {
      isometric.io.onKeyPressedModePlay(key);
    }
  }
}