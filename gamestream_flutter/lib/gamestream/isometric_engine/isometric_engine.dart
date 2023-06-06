

import 'dart:ui';

import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_minimap.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_renderer.dart';

import '../../library.dart';
import 'game_isometric_actions.dart';
import 'game_isometric_camera.dart';
import 'game_isometric_client_state.dart';
import 'game_isometric_editor.dart';
import 'game_isometric_nodes.dart';
import 'game_isometric_player.dart';
import 'game_isometric_server_state.dart';

class IsometricEngine {
  final actions = GameIsometricActions();
  final renderer = GameIsometricRenderer();
  final clientState = GameIsometricClientState();
  final serverState = GameIsometricServerState();
  final nodes = GameIsometricNodes();
  final minimap = GameIsometricMinimap();
  final editor = GameIsometricEditor();
  final player = GameIsometricPlayer();
  final camera = GameIsometricCamera();

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
  
  void update(){
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
}