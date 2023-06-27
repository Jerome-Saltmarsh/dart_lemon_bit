

import 'dart:ui';

import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

import 'ui/game_isometric_minimap.dart';
import 'classes/isometric_particles.dart';
import 'components/render/renderer_gameobjects.dart';
import 'components/render/renderer_particles.dart';
import 'components/src.dart';

class Isometric {
  final debug = IsometricDebug();
  final client = IsometricClient();
  final server = IsometricServer();
  final scene = IsometricScene();
  final minimap = IsometricMinimap();
  final editor = IsometricEditor();
  final player = IsometricPlayer();
  final camera = IsometricCamera();
  final particles = IsometricParticles();
  final ui = IsometricUI();

  late final events = IsometricEvents(client, gamestream);
  late final renderer = IsometricRender(
    rendererGameObjects: RendererGameObjects(scene),
    rendererParticles: RendererParticles(scene),
  );

  void drawCanvas(Canvas canvas, Size size) {
    if (server.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      particles.updateParticles();
    }
    client.interpolatePlayer();
    camera.update();
    renderer.render3D();
    renderer.renderEditMode();
    renderer.renderMouseTargetName();
    renderer.renderPlayerEnergy();

    debug.render(renderer);

    gamestream.rendersSinceUpdate.value++;
  }

  double get windLineRenderX {
    var windLineColumn = 0;
    var windLineRow = 0;
    if (client.windLine < scene.totalRows){
      windLineColumn = 0;
      windLineRow =  scene.totalRows - client.windLine - 1;
    } else {
      windLineRow = 0;
      windLineColumn = client.windLine - scene.totalRows + 1;
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
    client.updateTorchEmissionIntensity();
    client.updateParticleEmitters();
    client.update();
    player.updateMessageTimer();
    sendClientRequestUpdate();
  }

  Future sendClientRequestUpdate() async {
    gamestream.io.applyKeyboardInputToUpdateBuffer();
    gamestream.io.sendUpdateBuffer();
  }

  void revive() =>
      sendRequest(IsometricRequest.Revive);

  void setRain(int value) =>
      sendRequest(IsometricRequest.Weather_Set_Rain, value);

  void setWind(int value) =>
      sendRequest(IsometricRequest.Weather_Set_Wind, value);

  void setLightning(int value) =>
      sendRequest(IsometricRequest.Weather_Set_Lightning, value);

  void toggleBreeze() =>
      sendRequest(IsometricRequest.Weather_Toggle_Breeze);

  void setHour(int value) =>
      sendRequest(IsometricRequest.Time_Set_Hour, value);

  void selectNpcTalkOption(int index) =>
      sendRequest(IsometricRequest.Npc_Talk_Select_Option, index);

  void editorLoadGame(String name)=> sendRequest(IsometricRequest.Editor_Load_Game, name);

  void teleportDebugCharacterToMouse() =>
      sendRequest(IsometricRequest.Debug_Character_Teleport_To_Mouse);

  void DebugCharacterWalkToMouse() =>
      sendRequest(IsometricRequest.Debug_Character_Walk_To_Mouse);

  void debugCharacterToggleAutoAttack() =>
      sendRequest(IsometricRequest.Debug_Character_Toggle_Auto_Attack_Nearby_Enemies);

  void debugCharacterTogglePathFindingEnabled() =>
      sendRequest(IsometricRequest.Debug_Character_Toggle_Path_Finding_Enabled);

  void debugCharacterDebugUpdate() =>
      sendRequest(IsometricRequest.Debug_Character_Debug_Update);

  void sendRequest(IsometricRequest request, [dynamic message]) =>
      gamestream.network.sendClientRequest(
        ClientRequest.Isometric,
        '${request.index} $message',
      );
}