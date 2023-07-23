

import 'dart:math';

import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/games.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_response_reader.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/gamestream/games/game_scissors_paper_rock.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_read_response.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_text.dart';
import 'package:gamestream_flutter/lemon_websocket_client/connection_status.dart';
import 'package:gamestream_flutter/lemon_websocket_client/convert_http_to_wss.dart';
import 'package:gamestream_flutter/library.dart';

import '../../lemon_websocket_client/websocket_client_builder.dart';
import '../network/functions/detect_connection_region.dart';
import 'atlases/atlas.dart';
import 'atlases/atlas_nodes.dart';
import 'classes/src.dart';
import 'components/isometric_options.dart';
import 'components/render/classes/template_animation.dart';
import 'components/render/renderer_characters.dart';
import 'components/render/renderer_gameobjects.dart';
import 'components/render/renderer_particles.dart';
import 'components/src.dart';
import 'enums/cursor_type.dart';
import 'enums/emission_type.dart';
import 'mixins/src.dart';
import 'ui/game_isometric_minimap.dart';
import 'ui/isometric_constants.dart';

class Isometric extends WebsocketClientBuilder with
    IsometricScene,
    IsometricCharacters,
    IsometricParticles,
    IsometricAnimation,
    IsometricRender
{

  final operationStatus = Watch(OperationStatus.None);
  final region = Watch<ConnectionRegion?>(ConnectionRegion.LocalHost);
  var engineBuilt = false;
  final updateFrame = Watch(0);
  final audio = GameAudio();
  final serverFPS = Watch(0);
  late final error = Watch<GameError?>(null, onChanged: _onChangedGameError);
  late final account = Watch<Account?>(null, onChanged: onChangedAccount);
  late final gameType = Watch(GameType.Website, onChanged: onChangedGameType);
  late final game = Watch<Game>(games.website, onChanged: _onChangedGame);
  late final Games games;
  late final io = GameIO(this);
  late final rendersSinceUpdate = Watch(0, onChanged: onChangedRendersSinceUpdate);
  final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  late final Engine engine;
  var clearErrorTimer = -1;
  var nextEmissionSmoke = 0;
  var cursorType = IsometricCursorType.Hand;
  var srcXRainFalling = 6640.0;
  var srcXRainLanding = 6739.0;
  var messageStatusDuration = 0;
  var areaTypeVisibleDuration = 0;
  var nextLightingUpdate = 0;
  var totalActiveLights = 0;
  var interpolationPadding = 0.0;
  var torchEmissionStart = 0.8;
  var torchEmissionEnd = 1.0;
  var torchEmissionVal = 0.061;
  var torchEmissionT = 0.0;
  var nodesRaycast = 0;
  var windLine = 0;

  late final edit = Watch(false, onChanged:  onChangedEdit);
  late final messageStatus = Watch('', onChanged: onChangedMessageStatus);
  late final raining = Watch(false, onChanged: onChangedRaining);
  late final areaTypeVisible = Watch(false, onChanged: onChangedAreaTypeVisible);
  late final playerCreditsAnimation = Watch(0, onChanged: onChangedCredits);

  final overrideColor = WatchBool(false);
  final playerExperiencePercentage = Watch(0.0);
  final sceneEditable = Watch(false);
  final sceneName = Watch<String?>(null);
  final gameRunning = Watch(true);
  final weatherBreeze = Watch(false);
  final minutes = Watch(0);
  final lightningType = Watch(LightningType.Off);
  final watchTimePassing = Watch(false);
  final sceneUnderground = Watch(false);

  late final gameTimeEnabled = Watch(false, onChanged: onChangedGameTimeEnabled);
  late final lightningFlashing = Watch(false, onChanged: onChangedLightningFlashing);
  late final rainType = Watch(RainType.None, onChanged:  onChangedRain);
  late final seconds = Watch(0, onChanged:  onChangedSeconds);
  late final hours = Watch(0, onChanged:  onChangedHour);
  late final windTypeAmbient = Watch(WindType.Calm, onChanged:  onChangedWindType);

  final gameObjects = <IsometricGameObject>[];

  final debug = IsometricDebug();
  final minimap = IsometricMinimap();
  final editor = IsometricEditor();
  final player = IsometricPlayer();
  final camera = IsometricCamera();
  final ui = IsometricUI();
  final options = IsometricOptions();

  var totalProjectiles = 0;
  final projectiles = <IsometricProjectile>[];

  Isometric(){
    print('Isometric()');
    games = Games(this);
    updateFrame.onChanged(onChangedUpdateFrame);

    rendererNodes = RendererNodes(this);
    rendererProjectiles = RendererProjectiles(this);
    rendererCharacters = RendererCharacters(this);
    rendererParticles = RendererParticles(this);
    rendererGameObjects = RendererGameObjects(this);

    games.website.errorMessageEnabled.value = true;
    error.onChanged((GameError? error) {
      if (error == null) return;
      game.value.onGameError(error);
    });

    for (final entry in GameObjectType.Collection.entries){
      final type = entry.key;
      final values = entry.value;
      final atlas = Atlas.SrcCollection[type];
      for (final value in values){
        if (!atlas.containsKey(value)){
          // print('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
          throw Exception('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
        }
      }
    }

    for (final weaponType in WeaponType.values){
      try {
        TemplateAnimation.getWeaponPerformAnimation(weaponType);
      } catch (e){
        print('attack animation missing for ${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)}');
      }
    }
  }

  bool get playMode => !editMode;

  bool get editMode => edit.value;

  bool get lightningOn =>  lightningType.value != LightningType.Off;


  void drawCanvas(Canvas canvas, Size size) {
    if (gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      // particles.updateParticles();
    }
    camera.update();
    render3D();
    renderEditMode();
    renderMouseTargetName();
    debug.render(this);

    rendersSinceUpdate.value++;
  }

  double get windLineRenderX {
    var windLineColumn = 0;
    var windLineRow = 0;
    if (windLine < totalRows){
      windLineColumn = 0;
      windLineRow =  totalRows - windLine - 1;
    } else {
      windLineRow = 0;
      windLineColumn = windLine - totalRows + 1;
    }
    return (windLineRow - windLineColumn) * Node_Size_Half;
  }

  void update(){

    if (!connected)
      return;

    if (!gameRunning.value) {
      io.writeByte(ClientRequest.Update);
      io.applyKeyboardInputToUpdateBuffer(this);
      io.sendUpdateBuffer();
      return;
    }

    updateClearErrorTimer();
    game.value.update();

    audio.update();
    updateParticles();
    updateAnimationFrame();
    updateProjectiles();
    updateGameObjects();
    player.updateMessageTimer();
    readPlayerInputEdit();

    io.applyKeyboardInputToUpdateBuffer(this);
    io.sendUpdateBuffer();


    updateTorchEmissionIntensity();
    updateParticleEmitters();

    interpolationPadding = (( interpolationLength + 1) * Node_Size) / gamestream.engine.zoom;
    if (areaTypeVisible.value) {
      if (areaTypeVisibleDuration-- <= 0) {
        areaTypeVisible.value = false;
      }
    }

    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = '';
      }
    }

    if (nextLightingUpdate-- <= 0){
      nextLightingUpdate = IsometricConstants.Frames_Per_Lighting_Update;
      updateGameLighting();
    }

    updateCredits();
  }

  void readPlayerInputEdit() {
    if (!edit.value)
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
      gamestream.sendClientRequest(
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
    characters.clear();
    projectiles.clear();
    gameObjects.clear();
    totalProjectiles = 0;
    totalCharacters = 0;
  }

  IsometricGameObject findOrCreateGameObject(int id) {
    final instance = findGameObjectById(id) ?? IsometricGameObject(id);
    gameObjects.add(instance);
    return instance;
  }

  IsometricGameObject? findGameObjectById(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  void removeGameObjectById(int id )=>
      gameObjects.removeWhere((element) => element.id == id);

  void applyEmissionGameObjects() {
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      switch (gameObject.colorType) {
        case EmissionType.None:
          continue;
        case EmissionType.Color:
          applyVector3Emission(
            gameObject,
            hue: gameObject.emissionHue,
            saturation: gameObject.emissionSat,
            value: gameObject.emissionVal,
            alpha: gameObject.emissionAlp,
            intensity: gameObject.emission_intensity,
          );
          continue;
        case EmissionType.Ambient:
          applyVector3EmissionAmbient(gameObject,
            alpha: gameObject.emissionAlp,
            intensity: gameObject.emission_intensity,
          );
          continue;
      }
    }
  }

  /// TODO Optimize
  void updateGameObjects() {
    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      gameObject.update();
    }
  }

  void updateProjectiles() {
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      if (projectile.type == ProjectileType.Rocket) {
         spawnParticleSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
         spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
      }
      if (projectile.type == ProjectileType.Orb) {
         spawnParticleOrbShard(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          angle: randomAngle(),
        );
      }
    }
  }

  void projectShadow(IsometricPosition v3){
    if (!inBoundsPosition(v3)) return;

    final z = getProjectionZ(v3);
    if (z < 0) return;
    spawnParticle(
      type: ParticleType.Shadow,
      x: v3.x,
      y: v3.y,
      z: z,
      angle: 0,
      speed: 0,
      duration: 2,
    );
  }

  double getProjectionZ(IsometricPosition vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;

    while (true) {
      if (z < 0) return -1;
      final nodeIndex =  getIndexXYZ(x, y, z);
      final nodeOrientation =  nodeOrientations[nodeIndex];

      if (const <int> [
        NodeOrientation.None,
        NodeOrientation.Radial,
        NodeOrientation.Half_South,
        NodeOrientation.Half_North,
        NodeOrientation.Half_East,
        NodeOrientation.Half_West,
      ].contains(nodeOrientation)) {
        z -= IsometricConstants.Node_Height;
        continue;
      }
      if (z > Node_Height){
        return z + (z % Node_Height);
      } else {
        return Node_Height;
      }
    }
  }

  void clean() {
     colorStackIndex = -1;
     ambientStackIndex = -1;
  }

  void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      gamestream.audio.thunder(1.0);
    } else {
      updateGameLighting();
    }
  }

  void onChangedGameTimeEnabled(bool value){
    GameIsometricUI.timeVisible.value = value;
  }

  void applyEmissions(){
    totalActiveLights = 0;
    applyEmissionsLightSources();
    applyEmissionsCharacters();
    applyEmissionGameObjects();
    applyEmissionsProjectiles();
    applyCharacterColors();
    applyEmissionsParticles();

    applyEmissionEditorSelectedNode();
  }

  void applyEmissionEditorSelectedNode() {
    if (!editMode) return;
    if (( editor.gameObject.value == null ||  editor.gameObject.value!.colorType == EmissionType.None)){
       emitLightAmbient(
        index:  editor.nodeSelectedIndex.value,
        // hue:  scene.ambientHue,
        // saturation:  scene.ambientSaturation,
        // value:  scene.ambientValue,
        alpha: 0,
      );
    }
  }

  void applyCharacterColors(){
    for (var i = 0; i <  totalCharacters; i++){
      applyCharacterColor( characters[i]);
    }
  }

  void applyCharacterColor(IsometricCharacter character){
    character.color =  getRenderColorPosition(character);
  }

  void applyEmissionsProjectiles() {
    for (var i = 0; i <  totalProjectiles; i++){
      applyProjectileEmission( projectiles[i]);
    }
  }

  void applyProjectileEmission(IsometricProjectile projectile) {
    if (projectile.type == ProjectileType.Orb) {
       applyVector3Emission(projectile,
        hue: 100,
        saturation: 1,
        value: 1,
        alpha: 20,
      );
      return;
    }
    if (projectile.type == ProjectileType.Bullet) {
       applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
    if (projectile.type == ProjectileType.Fireball) {
       applyVector3Emission(projectile,
        hue: 167,
        alpha: 50,
        saturation: 1,
        value: 1,
      );
      return;
    }
    if (projectile.type == ProjectileType.Arrow) {
       applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
  }

  void clear() {
     player.position.x = -1;
     player.position.y = -1;
     player.gameDialog.value = null;
     player.npcTalkOptions.value = [];
     totalProjectiles = 0;
     particles.clear();
    gamestream.engine.zoom = 1;
  }

  int get bodyPartDuration =>  randomInt(120, 200);

  void updateTorchEmissionIntensity(){
    if (torchEmissionVal == 0) return;
    torchEmissionT += torchEmissionVal;

    if (
    torchEmissionT < torchEmissionStart ||
        torchEmissionT > torchEmissionEnd
    ) {
      torchEmissionT = clamp(torchEmissionT, torchEmissionStart, torchEmissionEnd);
      torchEmissionVal = -torchEmissionVal;
    }

     torch_emission_intensity = interpolateDouble(
      start: torchEmissionStart,
      end: torchEmissionEnd,
      t: torchEmissionT,
    );
  }

  void updateParticleEmitters(){
    nextEmissionSmoke--;
    if (nextEmissionSmoke > 0) return;
    nextEmissionSmoke = 20;
    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ObjectType.Barrel_Flaming) continue;
       spawnParticleSmoke(x: gameObject.x + giveOrTake(5), y: gameObject.y + giveOrTake(5), z: gameObject.z + 35);
    }
  }

  // PROPERTIES

  var _updateCredits = true;

  void updateCredits() {
    _updateCredits = !_updateCredits;
    if (!_updateCredits) return;
    final diff = playerCreditsAnimation.value -  player.credits.value;
    if (diff == 0) return;
    final diffAbs = diff.abs();
    final speed = max(diffAbs ~/ 10, 1);
    if (diff > 0) {
      playerCreditsAnimation.value -= speed;
    } else {
      playerCreditsAnimation.value += speed;
    }
  }

  void updateGameLighting(){
    if (overrideColor.value) return;
    if ( lightningFlashing.value) return;
    const Seconds_Per_Hour = 3600;
    const Seconds_Per_Hours_12 = Seconds_Per_Hour * 12;
    final totalSeconds = ( hours.value * Seconds_Per_Hour) + ( minutes.value * 60);

     ambientAlpha = ((totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) * 255).round();

    if ( rainType.value == RainType.Light){
       ambientAlpha += 20;
    }
    if ( rainType.value == RainType.Heavy){
       ambientAlpha += 40;
    }
     resetNodeColorsToAmbient();
  }

  void refreshRain(){
    switch ( rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if ( windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if ( windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = 1900;
        } else {
          srcXRainFalling = 1606;
        }
        break;
    }
  }

  void showMessage(String message){
    messageStatus.value = '';
    messageStatus.value = message;
  }

  void spawnConfettiPlayer() {
    for (var i = 0; i < 10; i++){
      spawnParticleConfetti(
        player.position.x,
        player.position.y,
         player.position.z,
      );
    }
  }

  void playSoundWindow() =>
      gamestream.audio.click_sound_8(1);

  void messageClear(){
    writeMessage('');
  }

  void writeMessage(String value){
     messageStatus.value = value;
  }

  void playAudioError(){
    gamestream.audio.errorSound15();
  }

  void onChangedAttributesWindowVisible(bool value){
     playSoundWindow();
  }

  void onChangedRaining(bool raining){
    raining ?  rainStart() :  rainStop();
     resetNodeColorsToAmbient();
  }

  void onChangedMessageStatus(String value){
    if (value.isEmpty){
       messageStatusDuration = 0;
    } else {
       messageStatusDuration = 150;
    }
  }

  void onChangedAreaTypeVisible(bool value) =>
       areaTypeVisibleDuration = value
          ? 150
          : 0;

  void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }

  void updateParticle(IsometricParticle particle) {
    if (!particle.active) return;
    if (particle.delay > 0) {
      particle.delay--;
      return;
    }

    if (outOfBoundsPosition(particle)){
      particle.deactivate();
      return;
    }

    if (particle.type == ParticleType.Light_Emission){
      const change = 0.125;
      if (particle.flash){
        particle.strength += change;
        if (particle.strength >= 1){
          particle.strength = 1.0;
          particle.flash = false;
        }
        return;
      }
      particle.strength -= change;
      if (particle.strength <= 0){
        particle.strength = 0;
        particle.duration = 0;
      }
      return;
    }

    if (particle.animation) {
      if (particle.duration-- <= 0) {
        particle.deactivate();
      }
      return;
    }

    final nodeIndex = getIndexPosition(particle);

    assert (nodeIndex >= 0);
    assert (nodeIndex < totalNodes);

    particle.nodeIndex = nodeIndex;
    final nodeType = nodeTypes[nodeIndex];
    particle.nodeType = nodeType;
    final airBorn =
        !particle.checkNodeCollision || (
            nodeType == NodeType.Empty        ||
                nodeType == NodeType.Rain_Landing ||
                nodeType == NodeType.Rain_Falling ||
                nodeType == NodeType.Grass_Long   ||
                nodeType == NodeType.Fireplace)    ;


    if (particle.checkNodeCollision && !airBorn) {
      particle.deactivate();
      return;
    }

    if (!airBorn){
      particle.z = (particle.indexZ + 1) * Node_Height;
      particle.applyFloorFriction();
    } else {
      if (particle.type == ParticleType.Smoke){
        final wind = gamestream.windTypeAmbient.value * 0.01;
        particle.xv -= wind;
        particle.yv += wind;
      }
    }
    final bounce = particle.zv < 0 && !airBorn;
    particle.updateMotion();

    if (outOfBoundsPosition(particle)){
      particle.deactivate();
      return;
    }

    if (bounce) {
      if (nodeType == NodeType.Water){
        return particle.deactivate();
      }
      if (particle.zv < -0.1){
        particle.zv = -particle.zv * particle.bounciness;
      } else {
        particle.zv = 0;
      }
    } else if (airBorn) {
      particle.applyAirFriction();
    }
    particle.applyLimits();
    particle.duration--;

    if (particle.duration <= 0) {
      particle.deactivate();
    }
  }

  void updateParticles() {
    nextParticleFrame--;

    for (final particle in particles) {
      if (!particle.active) continue;
      updateParticle(particle);
      if (nextParticleFrame <= 0){
        particle.frame++;
      }
    }
    if (nextParticleFrame <= 0) {
      nextParticleFrame = IsometricConstants.Frames_Per_Particle_Animation_Frame;
    }
  }

  IsometricParticle spawnParticleFire({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0
  }) =>
      spawnParticle(
        type: ParticleType.Fire,
        x: x,
        y: y,
        z: z,
        zv: 1,
        angle: 0,
        rotation: 0,
        speed: 0,
        scaleV: 0.01,
        weight: -1,
        duration: duration,
        scale: scale,
      )
        ..emitsLight = true
        ..lightHue = ambientHue
        ..lightSaturation = ambientSaturation
        ..lightValue = ambientValue
        ..alpha = 0
        ..checkNodeCollision = false
        ..strength = 0.5
  ;

  void spawnParticleLightEmissionAmbient({
    required double x,
    required double y,
    required double z,
  }) =>
      spawnParticle(
        type: ParticleType.Light_Emission,
        x: x,
        y: y,
        z: z,
        angle: 0,
        speed: 0,
        weight: 0,
        duration: 35,
        checkCollision: false,
        animation: true,
      )
        ..lightHue = ambientHue
        ..lightSaturation = ambientSaturation
        ..lightValue = ambientValue
        ..alpha = 0
        ..flash = true
        ..strength = 0.0
  ;

  @override
  void readResponse(int serverResponse){

    updateFrame.value++;

    switch (serverResponse) {
      case ServerResponse.Isometric_Characters:
        readIsometricCharacters();
        break;
      case ServerResponse.Api_Player:
        readApiPlayer();
        break;
      case ServerResponse.Api_SPR:
        readServerResponseApiSPR();
        break;
      case ServerResponse.Isometric:
        readIsometricResponse();
        break;
      case ServerResponse.GameObject:
        readGameObject();
        break;
      case ServerResponse.Projectiles:
        readProjectiles();
        break;
      case ServerResponse.Game_Event:
        readGameEvent();
        break;
      case ServerResponse.Player_Event:
        readPlayerEvent();
        break;
      case ServerResponse.Game_Time:
        readGameTime();
        break;
      case ServerResponse.Game_Type:
        final index = readByte();
        if (index >= GameType.values.length){
          throw Exception('invalid game type index $index');
        }
        gameType.value = GameType.values[index];
        break;
      case ServerResponse.Environment:
        readServerResponseEnvironment();
        break;
      case ServerResponse.Node:
        readNode();
        break;
      case ServerResponse.Player_Target:
        readIsometricPosition(player.target);
        break;
      case ServerResponse.Store_Items:
        readStoreItems();
        break;
      case ServerResponse.Npc_Talk:
        readNpcTalk();
        break;
      case ServerResponse.Weather:
        readWeather();
        break;
      case ServerResponse.Game_Properties:
        readGameProperties();
        break;
      case ServerResponse.Map_Coordinate:
        readMapCoordinate();
        break;
      case ServerResponse.Editor_GameObject_Selected:
        readEditorGameObjectSelected();
        break;
      case ServerResponse.Info:
        readServerResponseInfo();
        break;
      case ServerResponse.Fight2D:
        readServerResponseFight2D(games.fight2D);
        break;
      case ServerResponse.Capture_The_Flag:
        readCaptureTheFlag();
        break;
      case ServerResponse.MMO:
        readMMOResponse();
        break;
      case ServerResponse.Download_Scene:
        final name = readString();
        final length = readUInt16();
        final bytes = readBytes(length);
        engine.downloadBytes(bytes, name: '$name.scene');
        break;
      case ServerResponse.GameObject_Deleted:
        removeGameObjectById(readUInt16());
        break;
      case ServerResponse.Game_Error:
        final errorTypeIndex = readByte();
        error.value = GameError.fromIndex(errorTypeIndex);
        return;
      case ServerResponse.FPS:
        serverFPS.value = readUInt16();
        return;
      default:
        print('read error; index: $index');
        print(values);
        disconnect();
        return;
    }
  }

  @override
  void onConnectionLost() {
    games.website.error.value = 'Lost Connection';
  }

  void onChangedUpdateFrame(int value){
    rendersSinceUpdate.value = 0;
  }

  @override
  void onError(Object error, StackTrace stack) {
    if (error.toString().contains('NotAllowedError')){
      // https://developer.chrome.com/blog/autoplay/
      // This error appears when the game attempts to fullscreen
      // without the user having interacted first
      // TODO dispatch event on fullscreen failed
      onErrorFullscreenAuto();
      return;
    }
    print(error.toString());
    print(stack);
    games.website.error.value = error.toString();
  }

  @override
  void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
    bufferSizeTotal.value = 0;

    switch (connection) {
      case ConnectionStatus.Connected:
        engine.cursorType.value = CursorType.None;
        engine.zoomOnScroll = true;
        engine.zoom = 1.0;
        engine.targetZoom = 1.0;
        timeConnectionEstablished = DateTime.now();
        audio.enabledSound.value = true;
        if (!engine.isLocalHost) {
          engine.fullScreenEnter();
        }
        break;

      case ConnectionStatus.Done:
        engine.cameraX = 0;
        engine.cameraY = 0;
        engine.zoom = 1.0;
        engine.drawCanvasAfterUpdate = true;
        engine.cursorType.value = CursorType.Basic;
        engine.fullScreenExit();
        player.active.value = false;
        timeConnectionEstablished = null;
        clear();
        clean();
        gameObjects.clear();
        sceneEditable.value = false;
        gameType.value = GameType.Website;
        audio.enabledSound.value = false;
        break;
      case ConnectionStatus.Failed_To_Connect:
        games.website.error.value = 'Failed to connect';
        break;
      case ConnectionStatus.Invalid_Connection:
        games.website.error.value = 'Invalid Connection';
        break;
      case ConnectionStatus.Error:
        games.website.error.value = 'Connection Error';
        break;
      default:
        break;
    }

  }


  void readServerResponseInfo() {
    final info = readString();
    print(info);
  }

  void readApiPlayerEnergy() =>
      player.energyPercentage = readPercentage();

  void readPlayerHealth() {
    player.health.value = readUInt16();
    player.maxHealth.value = readUInt16();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(isometricEngine.editor.gameObject);

    final id = readUInt16();
    final gameObject = findGameObjectById(id);
    if (gameObject == null) throw Exception('could not find gameobject with id $id');
    editor.gameObject.value = gameObject;
    editor.gameObjectSelectedCollidable   .value = readBool();
    editor.gameObjectSelectedFixed        .value = readBool();
    editor.gameObjectSelectedCollectable  .value = readBool();
    editor.gameObjectSelectedPhysical     .value = readBool();
    editor.gameObjectSelectedPersistable  .value = readBool();
    editor.gameObjectSelectedGravity      .value = readBool();

    editor.gameObjectSelectedType.value          = gameObject.type;
    editor.gameObjectSelectedSubType.value       = gameObject.subType;
    editor.gameObjectSelected.value              = true;
    editor.cameraCenterSelectedObject();

    editor.gameObjectSelectedEmission.value = gameObject.colorType;
    editor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
  }

  void readIsometricCharacters(){
    totalCharacters = 0;

    while (true) {

      final compressionLevel = readByte();
      if (compressionLevel == CHARACTER_END) break;
      final character = getCharacterInstance();


      final stateAChanged = readBitFromByte(compressionLevel, 0);
      final stateBChanged = readBitFromByte(compressionLevel, 1);
      final changeTypeX = (compressionLevel & Hex00001100) >> 2;
      final changeTypeY =  (compressionLevel & Hex00110000) >> 4;
      final changeTypeZ = (compressionLevel & Hex11000000) >> 6;

      if (stateAChanged) {
        character.characterType = readByte();
        character.state = readByte();
        character.team = readByte();
        character.health = readPercentage();
      }

      if (stateBChanged){
        final animationAndFrameDirection = readByte();
        character.direction = (animationAndFrameDirection & Hex11100000) >> 5;
        assert (character.direction >= 0 && character.direction <= 7);
        character.animationFrame = (animationAndFrameDirection & Hex00011111);
      }



      assert (changeTypeX >= 0 && changeTypeX <= 2);
      assert (changeTypeY >= 0 && changeTypeY <= 2);
      assert (changeTypeZ >= 0 && changeTypeZ <= 2);

      if (changeTypeX == ChangeType.Small) {
        character.x += readInt8();
      } else if (changeTypeX == ChangeType.Big) {
        character.x = readDouble();
      }

      if (changeTypeY == ChangeType.Small) {
        character.y += readInt8();
      } else if (changeTypeY == ChangeType.Big) {
        character.y = readDouble();
      }

      if (changeTypeZ == ChangeType.Small) {
        character.z += readInt8();
      } else if (changeTypeZ == ChangeType.Big) {
        character.z = readDouble();
      }

      if (character.characterType == CharacterType.Template){
        readCharacterTemplate(character);
      }
      totalCharacters++;
    }
  }

  void readNpcTalk() {
    player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
      options.add(readString());
    }
    player.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    sceneEditable.value = readBool();
    sceneName.value = readString();
    gameRunning.value = readBool();
  }

  void readWeather() {
    rainType.value = readByte();
    weatherBreeze.value = readBool();
    lightningType.value = readByte();
    windTypeAmbient.value = readByte();
  }

  void readStoreItems() {
    final length = readUInt16();
    if (player.storeItems.value.length != length){
      player.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      player.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    nodeTypes[nodeIndex] = nodeType;
    nodeOrientations[nodeIndex] = nodeOrientation;
    /// TODO optimize
    onChangedNodes();
    editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readIsometricPosition(player.abilityTarget);
  }

  void readGameTime() {
    seconds.value = readUInt24();
  }

  double readDouble() => readInt16().toDouble();

  void readGameEvent(){
    final type = readByte();
    final x = readDouble();
    final y = readDouble();
    final z = readDouble();
    final angle = readDouble() * degreesToRadians;
    onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    totalProjectiles = readUInt16();
    while (totalProjectiles >= projectiles.length){
      projectiles.add(IsometricProjectile());
    }
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void readCharacterTemplate(IsometricCharacter character){

    final compression = readByte();

    final readA = readBitFromByte(compression, 0);
    final readB = readBitFromByte(compression, 1);
    final readC = readBitFromByte(compression, 2);

    if (readA){
      character.weaponType = readByte();
      character.bodyType = readByte();
      character.headType = readByte();
      character.legType = readByte();
    }

    if (readB){
      final lookDirectionWeaponState = readByte();
      character.lookDirection = readNibbleFromByte1(lookDirectionWeaponState);
      final weaponState = readNibbleFromByte2(lookDirectionWeaponState);
      character.weaponState = weaponState;
    }

    if (readC) {
      character.weaponStateDuration = readByte();
    } else {
      character.weaponStateDuration = 0;
    }
  }

  void readPlayerEvent() {
    onPlayerEvent(readByte());
  }

  void readIsometricPosition(IsometricPosition value){
    value.x = readDouble();
    value.y = readDouble();
    value.z = readDouble();
  }

  double readPercentage() => readByte() / 255.0;

  double readAngle() => readDouble() * degreesToRadians;

  Map<int, List<int>> readMapListInt(){
    final valueMap = <int, List<int>> {};
    final totalEntries = readUInt16();
    for (var i = 0; i < totalEntries; i++) {
      final key = readUInt16();
      final valueLength = readUInt16();
      final values = readUint16List(valueLength);
      valueMap[key] = values;
    }
    return valueMap;
  }

  void readServerResponseApiSPR() {
    switch (readByte()){
      case ApiSPR.Player_Positions:
        GameScissorsPaperRock.playerTeam = readByte();
        GameScissorsPaperRock.playerX = readDouble();
        GameScissorsPaperRock.playerY = readDouble();

        final total = readUInt16();
        GameScissorsPaperRock.totalPlayers = total;
        for (var i = 0; i < total; i++) {
          final player     = GameScissorsPaperRock.players[i];
          player.team      = readUInt8();
          player.x         = readInt16().toDouble();
          player.y         = readInt16().toDouble();
          player.targetX   = readInt16().toDouble();
          player.targetY   = readInt16().toDouble();
        }
        break;
    }
  }

  void readGameFight2DResponseCharacters(GameFight2D game) {
    final totalPlayers = readUInt16();
    assert (totalPlayers < GameFight2D.length);
    game.charactersTotal = totalPlayers;
    for (var i = 0; i < totalPlayers; i++) {
      game.characterState[i] = readByte();
      game.characterDirection[i] = readByte();
      game.characterIsBot[i] = readBool();
      game.characterDamage[i] = readUInt16();
      game.characterPositionX[i] = readInt16().toDouble();
      game.characterPositionY[i] = readInt16().toDouble();
      game.characterStateDuration[i] = readByte();
    }
  }

  CaptureTheFlagAIDecision readCaptureTheFlagAIDecision() => CaptureTheFlagAIDecision.values[readByte()];

  CaptureTheFlagAIRole readCaptureTheFlagAIRole() => CaptureTheFlagAIRole.values[readByte()];


  void onChangedGameType(GameType value) {
    print('onChangedGameType(${value.name})');
    io.reset();
    startGameByType(value);
  }

  void startGameByType(GameType gameType){
    game.value = games.mapGameTypeToGame(gameType);
  }

  @override
  void onScreenSizeChanged(
      double previousWidth,
      double previousHeight,
      double newWidth,
      double newHeight,
      ) => detectInputMode();

  void onDeviceTypeChanged(int deviceType){
    detectInputMode();
  }

  void startGameType(GameType gameType){
    connectToGame(gameType);
  }

  /// EVENT HANDLER (DO NOT CALL)
  void _onChangedGame(Game game) {
    // engine.onDrawCanvas = game.drawCanvas;
    // engine.onDrawForeground = game.renderForeground;
    engine.buildUI = game.buildUI;
    engine.onLeftClicked = game.onLeftClicked;
    engine.onRightClicked = game.onRightClicked;
    engine.onKeyPressed = game.onKeyPressed;
    engine.onMouseEnterCanvas = game.onMouseEnter;
    engine.onMouseExitCanvas = game.onMouseExit;
    game.onActivated();
  }

  void _onChangedGameError(GameError? gameError){
    print('_onChangedGameError($gameError)');
    if (gameError == null)
      return;

    clearErrorTimer = 300;
    playAudioError();
    switch (gameError) {
      case GameError.Unable_To_Join_Game:
        gamestream.games.website.error.value = 'unable to join game';
        disconnect();
        break;
      default:
        break;
    }
  }

  void onChangedAccount(Account? account) {
    // if (account == null) return;
    // final flag = 'subscription_status_${account.userId}';
    // if (storage.contains(flag)){
    //   final storedSubscriptionStatusString = storage.get<String>(flag);
    //   final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
    // }
  }

  void updateClearErrorTimer() {
    if (clearErrorTimer <= 0)
      return;

    clearErrorTimer--;
    if (clearErrorTimer > 0)
      return;

    error.value = null;
  }

  void render(Canvas canvas, Size size){
    if (!connected)
      return;

    drawCanvas(canvas, size);
    game.value.drawCanvas(canvas, size);
  }

  void doRenderForeground(Canvas canvas, Size size){
    if (!connected)
      return;

    renderForeground(canvas, size);
    game.value.renderForeground(canvas, size);
  }

  Future init(sharedPreferences) async {
    Images.loadImages();
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    print('isometric.build()');

    if (engineBuilt){
      return engine;
    }

    engineBuilt = true;
    engine = Engine(
      init: init,
      update: update,
      render: render,
      onDrawForeground: doRenderForeground,
      title: 'AMULET',
      themeData: ThemeData(fontFamily: 'VT323-Regular'),
      backgroundColor: IsometricColors.black,
      onError: onError,
      buildUI: games.website.buildUI,
      buildLoadingScreen: buildLoadingPage,
    );

    print("environment: ${engine.isLocalHost ? 'localhost' : 'production'}");
    print('time zone: ${detectConnectionRegion()}');
    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
    engine.drawCanvasAfterUpdate = false;
    renderResponse = true;
    engine.cursorType.value = CursorType.Basic;
    engine.deviceType.onChanged(onDeviceTypeChanged);
    engine.onScreenSizeChanged = onScreenSizeChanged;
    return engine;
  }

  Widget buildLoadingPage() =>
      Container(
        color: IsometricColors.black,
        alignment: Alignment.center,
        child: buildText('LOADING GAMESTREAM'),
      );

  @override
  void onReadRespondFinished() {

    if (renderResponse){
      engine.redrawCanvas();
    }
  }


  // FUNCTIONS
  void connectToRegion(ConnectionRegion region, String message) {
    print('connectToRegion(${region.name}');
    if (region == ConnectionRegion.LocalHost) {
      const portLocalhost = '8080';
      final wsLocalHost = 'ws://localhost:${portLocalhost}';
      connectToServer(wsLocalHost, message);
      return;
    }
    if (region == ConnectionRegion.Custom) {
      print('connecting to custom server');
      // print(gamestream.games.website.customConnectionStrongController.text);
      // connectToServer(
      //   gamestream.games.website.customConnectionStrongController.text,
      //   message,
      // );
      return;
    }
    connectToServer(convertHttpToWSS(region.url), message);
  }

  void connectLocalHost({int port = 8080, required String message}) {
    connectToServer('ws://localhost:$port', message);
  }

  void connectToServer(String uri, String message) {
    connect(uri: uri, message: '${ClientRequest.Join} $message');
  }

  void connectToGame(GameType gameType, [String message = '']) {
    final regionValue = region.value;
    if (regionValue == null) {
      throw Exception('region is null');
    }
    connectToRegion(regionValue, '${gameType.index} $message');
  }

  void sendClientRequest(int value, [dynamic message]) =>
      message != null ? send('${value} $message') : send(value);

  void detectInputMode() =>
      io.inputMode.value = engine.deviceIsComputer
          ? InputMode.Keyboard
          : InputMode.Touch;

}