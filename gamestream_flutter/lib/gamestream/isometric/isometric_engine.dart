

import 'dart:ui';

import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_minimap.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_gameobjects.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_io.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_particles.dart';

import '../../library.dart';
import 'isometric_actions.dart';
import 'isometric_camera.dart';
import 'isometric_client_state.dart';
import 'isometric_editor.dart';
import 'isometric_events.dart';
import 'isometric_nodes.dart';
import 'isometric_player.dart';
import 'isometric_server.dart';
import 'isometric_render.dart';

class IsometricEngine {
  final clientState = IsometricClientState();
  final server = IsometricServer();
  final nodes = IsometricNodes();
  final minimap = GameIsometricMinimap();
  final editor = IsometricEditor();
  final player = IsometricPlayer();
  final camera = IsometricCamera();
  final io = IsometricIO();
  final particles = IsometricParticles();

  late final events = IsometricEvents(clientState, gamestream);
  late final actions = IsometricActions(this);
  late final renderer = IsometricRender(
    rendererGameObjects: RendererGameObjects(nodes),
    rendererParticles: RendererParticles(nodes),
  );

  void drawCanvas(Canvas canvas, Size size) {
    if (server.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      particles.updateParticles();
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
    if (!server.gameRunning.value) {
      gamestream.network.sendClientRequestUpdate();
      return;
    }
    clientState.updateTorchEmissionIntensity();
    gamestream.animation.updateAnimationFrame();
    clientState.updateParticleEmitters();
    server.updateProjectiles();
    server.updateGameObjects();
    gamestream.audio.update();
    clientState.update();
    clientState.updatePlayerMessageTimer();
    gamestream.io.readPlayerInput();
    gamestream.network.sendClientRequestUpdate();
  }
}