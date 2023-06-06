
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_isometric_ui.dart';

class GameIsometric extends Game {

  GameIsometric() {
    gamestream.isometricEngine.camera.chaseTarget = gamestream.isometricEngine.player.position;
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    gamestream.isometricEngine.drawCanvas(canvas, size);
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    gamestream.isometricEngine.renderer.renderForeground(canvas, size);
  }

  @override
  void update() {
    gamestream.isometricEngine.update();
  }

  void sendIsometricClientRequest([dynamic message]) {
    gamestream.network.sendClientRequest(ClientRequest.Isometric, message);
  }

  @override
  void onActivated() {
    gamestream.isometricEngine.clientState.window_visible_player_creation.value = false;
    gamestream.isometricEngine.clientState.control_visible_respawn_timer.value = false;
    gamestream.audio.musicStop();
    engine.onLeftClicked = gamestream.io.touchController.onClick;
    engine.onMouseMoved = gamestream.io.touchController.onMouseMoved;
    gamestream.isometricEngine.clientState.control_visible_player_weapons.value = true;
    gamestream.isometricEngine.clientState.control_visible_scoreboard.value = true;
    gamestream.isometricEngine.clientState.control_visible_player_power.value = true;

    if (!engine.isLocalHost) {
      engine.fullScreenEnter();
    }
  }

  @override
  Widget buildUI(BuildContext context) {
    return GameIsometricUI.buildUI();
  }

  static double convertWorldToGridX(double x, double y) =>
      x + y;

  static double convertWorldToGridY(double x, double y) =>
      y - x;

  static int convertWorldToRow(double x, double y, double z) =>
      (x + y + z) ~/ Node_Size;

  static int convertWorldToColumn(double x, double y, double z) =>
      (y - x + z) ~/ Node_Size;
}