
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_client_state.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_minimap.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_player.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_renderer.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_isometric_actions.dart';
import 'game_isometric_camera.dart';
import 'game_isometric_editor.dart';
import 'game_isometric_nodes.dart';
import 'game_isometric_server_state.dart';
import 'game_isometric_ui.dart';

class GameIsometric extends Game {
  final camera = GameIsometricCamera();
  final clientState = GameIsometricClientState();
  final serverState = GameIsometricServerState();
  final nodes = GameIsometricNodes();
  final actions = GameIsometricActions();
  final renderer = GameIsometricRenderer();
  final editor = GameIsometricEditor();
  final player = GameIsometricPlayer();
  final minimap = GameIsometricMinimap();

  @override
  void drawCanvas(Canvas canvas, Size size) {
    if (serverState.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      clientState.updateParticles();
    }
    clientState.interpolatePlayer();
    camera.update();
    renderer.render3D();
    clientState.renderEditMode();
    renderer.renderMouseTargetName();
    renderer.renderPlayerEnergy();
    clientState.rendersSinceUpdate.value++;
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    renderer.renderForeground(canvas, size);
  }

  @override
  void update() {
    if (!serverState.gameRunning.value) {
      gamestream.network.sendClientRequestUpdate();
      return;
    }
    clientState.updateTorchEmissionIntensity();
    gamestream.animation.updateAnimationFrame();
    clientState.updateParticleEmitters();
    serverState.updateProjectiles();
    serverState.updateGameObjects();
    gamestream.audio.update();
    clientState.update();
    clientState.updatePlayerMessageTimer();
    gamestream.io.readPlayerInput();
    gamestream.network.sendClientRequestUpdate();
  }

  @override
  void onActivated() {
    clientState.window_visible_player_creation.value = false;
    clientState.control_visible_respawn_timer.value = false;
    gamestream.audio.musicStop();
    engine.onLeftClicked = gamestream.io.touchController.onClick;
    engine.onMouseMoved = gamestream.io.touchController.onMouseMoved;
    clientState.control_visible_player_weapons.value = true;
    clientState.control_visible_scoreboard.value = true;
    clientState.control_visible_player_power.value = true;

    if (!engine.isLocalHost) {
      engine.fullScreenEnter();
    }
  }

  @override
  Widget buildUI(BuildContext context) {
    return GameIsometricUI.buildUI();
  }

  double get windLineRenderX {
    var windLineColumn = 0;
    var windLineRow = 0;
    if (clientState.windLine < nodes.totalRows){
      windLineColumn = 0;
      windLineRow =  nodes.totalRows - clientState.windLine - 1;
    } else {
      windLineRow = 0;
      windLineColumn = clientState.windLine - nodes.totalRows + 1;
    }
    return (windLineRow - windLineColumn) * Node_Size_Half;
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