

import 'dart:ui';

import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_minimap.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_gameobjects.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_io.dart';

import '../../library.dart';
import 'isometric_actions.dart';
import 'isometric_camera.dart';
import 'isometric_client_state.dart';
import 'isometric_editor.dart';
import 'isometric_events.dart';
import 'isometric_nodes.dart';
import 'isometric_player.dart';
import 'isometric_server.dart';

class IsometricEngine {
  final clientState = IsometricClientState();
  final serverState = IsometricServer();
  final nodes = IsometricNodes();
  final minimap = GameIsometricMinimap();
  final editor = IsometricEditor();
  final player = IsometricPlayer();
  final camera = IsometricCamera();
  final io = IsometricIO();

  late final events = IsometricEvents(clientState, gamestream);
  late final actions = IsometricActions(this);
  late final renderer = GameIsometricRenderer(
    rendererGameObjects: RendererGameObjects(nodes),
    rendererParticles: RendererParticles(nodes),
  );

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