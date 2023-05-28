
import 'dart:ui';

import 'package:flutter/src/widgets/framework.dart';
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/touch_controller.dart';

import '../classes/game.dart';



class GameCombat extends Game {
  @override
  void drawCanvas(Canvas canvas, Size size) {
    if (ServerState.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      GameState.updateParticles();
    }
    GameState.interpolatePlayer();
    GameCamera.update();
    GameRender.render3D();
    GameState.renderEditMode();
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
    GameState.updateTorchEmissionIntensity();
    GameAnimation.updateAnimationFrame();
    GameState.updateParticleEmitters();
    ServerState.updateProjectiles();
    ServerState.updateGameObjects();
    gamestream.audio.update();
    ClientState.update();
    GameState.updatePlayerMessageTimer();
    gamestream.io.readPlayerInput();
    gamestream.network.sendClientRequestUpdate();
  }

  @override
  void onActivated() {
    ClientState.window_visible_player_creation.value = false;
    ClientState.control_visible_respawn_timer.value = false;
    gamestream.audio.musicStop();
    Engine.onLeftClicked = TouchController.onClick;
    Engine.onMouseMoved = TouchController.onMouseMoved;
    ClientState.control_visible_player_weapons.value = true;
    ClientState.control_visible_scoreboard.value = true;
    ClientState.control_visible_player_power.value = true;

    if (!Engine.isLocalHost) {
      Engine.fullScreenEnter();
    }
  }

  @override
  Widget buildUI(BuildContext context) {
    return GameUI.buildUI();
  }
}
