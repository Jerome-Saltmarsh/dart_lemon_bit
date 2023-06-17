

import 'dart:ui';

import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_minimap.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_gameobjects.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_io.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_ui.dart';

import '../../library.dart';
import 'components/isometric_actions.dart';
import 'components/isometric_camera.dart';
import 'components/isometric_client_state.dart';
import 'components/isometric_editor.dart';
import 'components/isometric_events.dart';
import 'components/isometric_nodes.dart';
import 'components/isometric_player.dart';
import 'components/isometric_server.dart';
import 'components/isometric_render.dart';

class Isometric {
  final clientState = IsometricClientState();
  final server = IsometricServer();
  final nodes = IsometricNodes();
  final minimap = GameIsometricMinimap();
  final editor = IsometricEditor();
  final player = IsometricPlayer();
  final camera = IsometricCamera();
  final io = IsometricIO();
  final particles = IsometricParticles();
  final ui = IsometricUI();

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
      sendClientRequestUpdate();
      return;
    }
    gamestream.audio.update();
    gamestream.animation.updateAnimationFrame();
    gamestream.io.readPlayerInput();
    server.updateProjectiles();
    server.updateGameObjects();
    clientState.updateTorchEmissionIntensity();
    clientState.updateParticleEmitters();
    clientState.update();
    player.updateMessageTimer();
    sendClientRequestUpdate();
  }

  Future sendClientRequestUpdate() async {
    gamestream.io.applyKeyboardInputToUpdateBuffer();
    gamestream.io.sendUpdateBuffer();
    gamestream.io.setCursorAction(CursorAction.None);
  }

  void revive() =>
      request(IsometricRequest.Revive);

  void setRain(int value) =>
      request(IsometricRequest.Weather_Set_Rain, value);

  void setWind(int value) =>
      request(IsometricRequest.Weather_Set_Wind, value);

  void setLightning(int value) =>
      request(IsometricRequest.Weather_Set_Lightning, value);

  void request(IsometricRequest request, [dynamic message]) =>
      gamestream.network.sendClientRequest(
        ClientRequest.Isometric,
        '${request.index} $message',
      );

}