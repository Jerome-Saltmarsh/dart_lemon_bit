
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/games/isometric/game_isometric_client_state.dart';
import 'package:gamestream_flutter/games/isometric/game_isometric_nodes.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/touch_controller.dart';

import 'game_isometric_camera.dart';

class GameIsometric extends Game {
  final camera = GameIsometricCamera();
  final clientState = GameIsometricClientState();
  final nodes = GameIsometricNodes();

  @override
  void drawCanvas(Canvas canvas, Size size) {
    if (ServerState.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      clientState.updateParticles();
    }
    clientState.interpolatePlayer();
    camera.update();
    GameRender.render3D();
    clientState.renderEditMode();
    GameRender.renderMouseTargetName();
    GameCanvas.renderPlayerEnergy();
    ClientState.rendersSinceUpdate.value++;
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    GameCanvas.renderForeground(canvas, size);
  }

  @override
  void update() {
    if (!ServerState.gameRunning.value) {
      gamestream.network.sendClientRequestUpdate();
      return;
    }
    clientState.updateTorchEmissionIntensity();
    gamestream.animation.updateAnimationFrame();
    clientState.updateParticleEmitters();
    ServerState.updateProjectiles();
    ServerState.updateGameObjects();
    gamestream.audio.update();
    ClientState.update();
    clientState.updatePlayerMessageTimer();
    gamestream.io.readPlayerInput();
    gamestream.network.sendClientRequestUpdate();
  }

  @override
  void onActivated() {
    ClientState.window_visible_player_creation.value = false;
    ClientState.control_visible_respawn_timer.value = false;
    gamestream.audio.musicStop();
    engine.onLeftClicked = TouchController.onClick;
    engine.onMouseMoved = TouchController.onMouseMoved;
    ClientState.control_visible_player_weapons.value = true;
    ClientState.control_visible_scoreboard.value = true;
    ClientState.control_visible_player_power.value = true;

    if (!engine.isLocalHost) {
      engine.fullScreenEnter();
    }
  }

  @override
  Widget buildUI(BuildContext context) {
    return GameUI.buildUI();
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
}