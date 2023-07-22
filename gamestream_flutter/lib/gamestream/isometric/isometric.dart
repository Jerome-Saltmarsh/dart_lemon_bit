

import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_gameobject.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_options.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/library.dart';

import 'components/render/renderer_characters.dart';
import 'ui/game_isometric_minimap.dart';
import 'classes/isometric_particles.dart';
import 'components/render/renderer_gameobjects.dart';
import 'components/render/renderer_particles.dart';
import 'components/src.dart';

class Isometric {
  final animation = IsometricAnimation();
  final debug = IsometricDebug();
  final client = IsometricClient();
  final server = IsometricServer();
  final scene = IsometricScene();
  final minimap = IsometricMinimap();
  final editor = IsometricEditor();
  final player = IsometricPlayer();
  final camera = IsometricCamera();
  final ui = IsometricUI();
  final options = IsometricOptions();

  late final particles = IsometricParticles(scene);
  late final events = IsometricEvents(client, gamestream);
  late final renderer = IsometricRender(
    rendererGameObjects: RendererGameObjects(scene),
    rendererParticles: RendererParticles(scene, particles.particles),
    rendererCharacters: RendererCharacters(scene),
    rendererNodes: RendererNodes(scene),
    rendererProjectiles: RendererProjectiles(scene),
  );

  void drawCanvas(Canvas canvas, Size size) {
    if (server.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      // particles.updateParticles();
    }
    // client.interpolatePlayer();
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
      gamestream.io.writeByte(ClientRequest.Update);
      gamestream.io.applyKeyboardInputToUpdateBuffer();
      gamestream.io.sendUpdateBuffer();
      return;
    }

    gamestream.audio.update();
    particles.updateParticles();
    animation.updateAnimationFrame();
    server.updateProjectiles();
    server.updateGameObjects();
    client.update();
    player.updateMessageTimer();
    readPlayerInputEdit();

    gamestream.io.applyKeyboardInputToUpdateBuffer();
    gamestream.io.sendUpdateBuffer();
  }

  void readPlayerInputEdit() {
    if (!client.edit.value)
      return;

    if (gamestream.engine.keyPressedSpace) {
      gamestream.engine.panCamera();
    }
    if (gamestream.engine.keyPressed(KeyCode.Delete)) {
      editor.delete();
    }
    if (gamestream.io.getInputDirectionKeyboard() != IsometricDirection.None) {
      actionSetModePlay();
    }
    return;
  }

  void revive() =>
      sendIsometricRequest(IsometricRequest.Revive);

  void setRain(int value) =>
      sendIsometricRequest(IsometricRequest.Weather_Set_Rain, value);

  void setWind(int value) =>
      sendIsometricRequest(IsometricRequest.Weather_Set_Wind, value);

  void setLightning(int value) =>
      sendIsometricRequest(IsometricRequest.Weather_Set_Lightning, value);

  void toggleBreeze() =>
      sendIsometricRequest(IsometricRequest.Weather_Toggle_Breeze);

  void setHour(int value) =>
      sendIsometricRequest(IsometricRequest.Time_Set_Hour, value);

  void editorLoadGame(String name)=> sendIsometricRequest(IsometricRequest.Editor_Load_Game, name);

  void moveSelectedColliderToMouse() =>
      sendIsometricRequest(IsometricRequest.Move_Selected_Collider_To_Mouse);

  void DebugCharacterWalkToMouse() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Walk_To_Mouse);

  void debugCharacterToggleAutoAttack() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Toggle_Auto_Attack_Nearby_Enemies);

  void debugCharacterTogglePathFindingEnabled() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Toggle_Path_Finding_Enabled);

  void debugCharacterToggleRunToDestination() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Toggle_Run_To_Destination);

  void debugCharacterDebugUpdate() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Debug_Update);

  void selectGameObject(IsometricGameObject gameObject) =>
      sendIsometricRequest(IsometricRequest.Select_GameObject, '${gameObject.id}');

  void debugCharacterSetCharacterType(int characterType) =>
      sendIsometricRequest(
          IsometricRequest.Debug_Character_Set_Character_Type,
          characterType,
      );

  void debugCharacterSetWeaponType(int weaponType) =>
      sendIsometricRequest(
          IsometricRequest.Debug_Character_Set_Weapon_Type,
          weaponType,
      );

  void debugSelect() =>
      sendIsometricRequest(IsometricRequest.Debug_Select);

  void debugCommand() =>
      sendIsometricRequest(IsometricRequest.Debug_Command);

  void debugAttack() =>
      sendIsometricRequest(IsometricRequest.Debug_Attack);

  void toggleDebugging() =>
      sendIsometricRequest(IsometricRequest.Toggle_Debugging);

  void sendIsometricRequest(IsometricRequest request, [dynamic message]) =>
      gamestream.network.sendClientRequest(
        ClientRequest.Isometric,
        '${request.index} $message',
      );

  void onPlayerInitialized(){
    player.position.x = 0;
    player.position.y = 0;
    player.position.z = 0;
    player.previousPosition.x = 0;
    player.previousPosition.y = 0;
    player.previousPosition.z = 0;
    player.indexZ = 0;
    player.indexRow = 0;
    player.indexColumn = 0;
    server.characters.clear();
    server.projectiles.clear();
    server.gameObjects.clear();
    server.totalProjectiles = 0;
    server.totalCharacters = 0;
    server.totalPlayers = 0;
    server.totalZombies = 0;
    server.totalNpcs = 0;
  }
}