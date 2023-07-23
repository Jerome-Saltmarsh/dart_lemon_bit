
import 'dart:ui' as ui;
import 'dart:math';

import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/audio/audio_single.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/games.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_response_reader.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_read_response.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
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

  static const Server_FPS = 45;

  late final messageBoxVisible = Watch(false, clamp: (bool value) {
    return value;
  }, onChanged: onVisibilityChangedMessageBox);

  final textEditingControllerMessage = TextEditingController();
  final textFieldMessage = FocusNode();
  final panelTypeKey = <int, GlobalKey>{};
  final playerTextStyle = TextStyle(color: Colors.white);
  final timeVisible = Watch(true);

  final windowOpenMenu = WatchBool(false);
  final operationStatus = Watch(OperationStatus.None);
  final region = Watch<ConnectionRegion?>(ConnectionRegion.LocalHost);
  var engineBuilt = false;
  final updateFrame = Watch(0);
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

  late final GameAudio audio;
  late final IsometricDebug debug;
  late final IsometricEditor editor;
  late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricPlayer player;
  final options = IsometricOptions();

  var totalProjectiles = 0;
  final projectiles = <IsometricProjectile>[];

  Isometric(){
    print('Isometric()');
    audio = GameAudio(this);
    editor = IsometricEditor(this);
    debug = IsometricDebug(this);
    minimap = IsometricMinimap(this);
    camera = IsometricCamera(this);
    mouse = IsometricMouse(this);
    player = IsometricPlayer(this);
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

    interpolationPadding = (( interpolationLength + 1) * Node_Size) / engine.zoom;
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

    if (engine.keyPressedSpace) {
      engine.panCamera();
    }
    if (engine.keyPressed(KeyCode.Delete)) {
      editor.delete();
    }
    if (io.getInputDirectionKeyboard() != IsometricDirection.None) {
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
      sendClientRequest(
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
            intensity: gameObject.emissionIntensity,
          );
          continue;
        case EmissionType.Ambient:
          applyVector3EmissionAmbient(gameObject,
            alpha: gameObject.emissionAlp,
            intensity: gameObject.emissionIntensity,
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
      audio.thunder(1.0);
    } else {
      updateGameLighting();
    }
  }

  void onChangedGameTimeEnabled(bool value){
    timeVisible.value = value;
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
    engine.zoom = 1;
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
      audio.click_sound_8(1);

  void messageClear(){
    writeMessage('');
  }

  void writeMessage(String value){
     messageStatus.value = value;
  }

  void playAudioError(){
    audio.errorSound15();
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
    audio.coins.play();
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
        final wind = windTypeAmbient.value * 0.01;
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
    editor.gameObjectSelectedEmissionIntensity.value = gameObject.emissionIntensity;
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
        games.website.error.value = 'unable to join game';
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

    renderCursor(canvas);
    playerAimTargetNameText();

    if (io.inputModeTouch) {
      io.touchController.render(canvas);
    }

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


  void playAudioSingleV3({
    required AudioSingle audioSingle,
    required IsometricPosition position,
    double maxDistance = 600}) => playAudioXYZ(
        audioSingle,
        position.x,
        position.y,
        position.z,
        maxDistance: maxDistance,
    );

  void playAudioXYZ(
    AudioSingle audioSingle,
    double x,
    double y,
    double z,{
      double maxDistance = 600,
    }){
    if (!audio.enabledSound.value) return;
    // TODO calculate distance from camera

    final distanceFromPlayer = getDistanceXYZ(x, y, z, player.x, player.y, player.z);;
    final distanceVolume = GameAudio.convertDistanceToVolume(
      distanceFromPlayer,
      maxDistance: maxDistance,
    );
    audioSingle.play(volume: distanceVolume);
    // play(volume: distanceVolume);
  }

  void refreshGameObjectEmissionColor(IsometricGameObject gameObject){
    gameObject.emissionColor = hsvToColor(
      hue: interpolate(start: ambientHue, end: gameObject.emissionHue , t: gameObject.emissionIntensity),
      saturation: interpolate(start: ambientSaturation, end: gameObject.emissionSat, t: gameObject.emissionIntensity),
      value: interpolate(start: ambientValue, end: gameObject.emissionVal, t: gameObject.emissionIntensity),
      opacity: interpolate(start: ambientAlpha, end: gameObject.emissionAlp, t: gameObject.emissionIntensity),
    );
  }

  bool isOnscreen(IsometricPosition position) {
    const Pad_Distance = 75.0;
    final rx = position.renderX;

    if (rx < engine.Screen_Left - Pad_Distance || rx > engine.Screen_Right + Pad_Distance)
      return false;

    final ry = position.renderY;
    return ry > engine.Screen_Top - Pad_Distance && ry < engine.Screen_Bottom + Pad_Distance;
  }

  Color get color => engine.paint.color;

  set color(Color color) => engine.paint.color = color;

  void applyEmissionsParticles() {
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      final particle = particles[i];
      if (!particle.active) continue;
      if (!particle.emitsLight) continue;
      emitLightAHSVShadowed(
        index: getIndexPosition(particle),
        hue: particle.lightHue,
        saturation: particle.lightSaturation,
        value: particle.lightValue,
        alpha: particle.alpha,
      );
    }
  }

  void renderShadow(double x, double y, double z, {double scale = 1}) =>
      engine.renderSprite(
        image: Images.atlas_gameobjects,
        dstX: (x - y) * 0.5,
        dstY: ((y + x) * 0.5) - z,
        srcX: 0,
        srcY: 32,
        srcWidth: 8,
        srcHeight: 8,
        scale: scale,
      );

  bool isPerceptiblePosition(IsometricPosition position) {
    if (!player.playerInsideIsland)
      return true;

    if (outOfBoundsPosition(position))
      return false;

    final index = getIndexPosition(position);
    final indexRow = getIndexRow(index);
    final indexColumn = getIndexRow(index);
    final i = indexRow * totalColumns + indexColumn;
    // TODO REFACTOR
    if (!rendererNodes.island[i])
      return true;
    final indexZ = getIndexZ(index);
    if (indexZ > player.indexZ + 2)
      return false;

    // TODO REFACTOR
    return rendererNodes.visible3D[index];
  }

  void emitLightAmbient({
    required int index,
    required int alpha,
  }){

    if (dynamicShadows) {
      emitLightAmbientShadows(
        index: index,
        alpha: alpha,
      );
      return;
    }

    if (index < 0) return;
    if (index >= totalNodes) return;

    final zIndex = index ~/ area;
    final rowIndex = (index - (zIndex * area)) ~/ totalColumns;
    final columnIndex = convertNodeIndexToIndexY(index);
    final radius = 6;
    final zMin = max(zIndex - radius, 0);
    final zMax = min(zIndex + radius, totalZ);
    final rowMin = max(rowIndex - radius, 0);
    final rowMax = min(rowIndex + radius, totalRows);
    final columnMin = max(columnIndex - radius, 0);
    final columnMax = min(columnIndex + radius, totalColumns);
    final rowInitInit = totalColumns * rowMin;
    var zTotal = zMin * area;

    const r = 4;
    final dstXLeft = IsometricRender.rowColumnZToRenderX(rowIndex + r, columnIndex - r);
    if (dstXLeft < engine.Screen_Left)    return;
    final dstXRight = IsometricRender.rowColumnZToRenderX(rowIndex - r, columnIndex + r);
    if (dstXRight > engine.Screen_Right)   return;
    final dstYTop = IsometricRender.rowColumnZToRenderY(rowIndex + r, columnIndex + r, zIndex);
    if (dstYTop <  engine.Screen_Top) return;
    final dstYBottom = IsometricRender.rowColumnZToRenderY(rowIndex - r, columnIndex - r, zIndex);
    if (dstYBottom > engine.Screen_Bottom) return;

    for (var z = zMin; z < zMax; z++) {
      var rowInit = rowInitInit;

      for (var row = rowMin; row <= rowMax; row++){
        final a = (zTotal) + (rowInit);
        rowInit += totalColumns;
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column <= columnMax; column++) {
          final nodeIndex = a + column;
          final distanceValue = clamp(b + (column - columnIndex).abs() - 2, 0, 6);
          if (distanceValue > 5) continue;
          ambientStackIndex++;
          ambientStack[ambientStackIndex] = nodeIndex;

          final intensity = 1.0 - interpolations[clamp(distanceValue, 0, 7)];
          final nodeAlpha = hsvAlphas[nodeIndex];
          if (nodeAlpha < alpha) continue;
          hsvAlphas[nodeIndex] = linearInterpolateInt(hsvAlphas[nodeIndex], alpha      , intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  void applyEmissionsLightSources() {
    for (var i = 0; i < nodesLightSourcesTotal; i++){
      final nodeIndex = nodesLightSources[i];
      final nodeType = nodeTypes[nodeIndex];

      switch (nodeType){
        case NodeType.Torch:
          emitLightAmbient(
            index: nodeIndex,
            alpha: linearInterpolateInt(
              ambientHue,
              0,
              torch_emission_intensity,
            ),
          );
          break;
      }
    }
  }

  void applyVector3EmissionAmbient(IsometricPosition v, {
    required int alpha,
    double intensity = 1.0,
  }){
    assert (intensity >= 0);
    assert (intensity <= 1);
    assert (alpha >= 0);
    assert (alpha <= 255);
    if (!inBoundsPosition(v)) return;
    emitLightAmbient(
      index: getIndexPosition(v),
      alpha: linearInterpolateInt(ambientHue, alpha , intensity),
    );
  }

  void renderCircleAroundPlayer({required double radius}) =>
      renderCircleAtPosition(
        position: player.position,
        radius: radius,
      );

  void setColorWhite(){
    engine.setPaintColorWhite();
  }

  void spawnPurpleFireExplosion(double x, double y, double z, {int amount = 5}){

    playAudioXYZ(audio.magical_impact_16,x, y, z);

    for (var i = 0; i < amount; i++) {
      spawnParticleFirePurple(
        x: x + giveOrTake(5),
        y: y + giveOrTake(5),
        z: z, speed: 1,
        angle: randomAngle(),
      );
    }

    spawnParticleLightEmission(
      x: x,
      y: y,
      z: z,
      hue: 259,
      saturation: 45,
      value: 95,
      alpha: 0,
    );
  }

  void emitLightAHSVShadowed({
    required int index,
    required int alpha,
    required int hue,
    required int saturation,
    required int value,
    double intensity = 1.0,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final padding = interpolationPadding;
    final rx = getIndexRenderX(index);
    if (rx < engine.Screen_Left - padding) return;
    if (rx > engine.Screen_Right + padding) return;
    final ry = getIndexRenderY(index);
    if (ry < engine.Screen_Top - padding) return;
    if (ry > engine.Screen_Bottom + padding) return;

    totalActiveLights++;

    final row = getIndexRow(index);
    final column = getIndexColumn(index);
    final z = getIndexZ(index);

    final nodeType = nodeTypes[index];
    final nodeOrientation = nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!isNodeTypeTransparent(nodeType)){
      if (const [
        NodeOrientation.Half_North,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vxStart = 0;
      }

      if (const [
        NodeOrientation.Half_South,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vxEnd = 0;
      }

      if (const [
        NodeOrientation.Half_East,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vyStart = 0;
      }

      if (const [
        NodeOrientation.Half_West,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vyEnd = 0;
      }
    }

    final h = linearInterpolateInt(ambientHue, hue , intensity);
    final s = linearInterpolateInt(ambientSaturation, saturation, intensity);
    final v = linearInterpolateInt(ambientValue, value, intensity);
    final a = linearInterpolateInt(ambientAlpha, alpha, intensity);

    applyAHSV(
      index: index,
      alpha: a,
      hue: h,
      saturation: s,
      value: v,
      interpolation: 0,
    );

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeAHSV(
            row: row,
            column: column,
            z: z,
            interpolation: -1,
            alpha: a,
            hue: h,
            saturation: s,
            value: v,
            vx: vx,
            vy: vy,
            vz: vz,
          );
        }
      }
    }
  }

  /// @hue a number between 0 and 360
  /// @saturation a number between 0 and 100
  /// @value a number between 0 and 100
  /// @alpha a number between 0 and 255
  /// @intensity a number between 0.0 and 1.0
  void applyVector3Emission(IsometricPosition v, {
    required int hue,
    required int saturation,
    required int value,
    required int alpha,
    double intensity = 1.0,
  }){
    if (!inBoundsPosition(v)) return;
    emitLightAHSVShadowed(
      index: getIndexPosition(v),
      hue: hue,
      saturation: saturation,
      value: value,
      alpha: alpha,
      intensity: intensity,
    );
  }


  void renderLine(double x1, double y1, double z1, double x2, double y2, double z2) =>
      engine.renderLine(
        renderX(x1, y1, z1),
        renderY(x1, y1, z1),
        renderX(x2, y2, z2),
        renderY(x2, y2, z2),
      );


  static double renderX(double x, double y, double z) => (x - y) * 0.5;

  static double renderY(double x, double y, double z) => ((x + y) * 0.5) - z;

  void renderCircle(double x, double y, double z, double radius, {int sections = 12}){
    if (radius <= 0) return;
    if (sections < 3) return;

    final anglePerSection = pi2 / sections;
    var lineX1 = adj(0, radius);
    var lineY1 = opp(0, radius);
    var lineX2 = lineX1;
    var lineY2 = lineY1;
    for (var i = 1; i <= sections; i++){
      final a = i * anglePerSection;
      lineX2 = adj(a, radius);
      lineY2 = opp(a, radius);
      renderLine(
        x + lineX1,
        y + lineY1,
        z,
        x + lineX2,
        y + lineY2,
        z,
      );
      lineX1 = lineX2;
      lineY1 = lineY2;
    }
  }

  void renderCircleAtPosition({
    required IsometricPosition position,
    required double radius,
    int sections = 12,
  })=> renderCircle(position.x, position.y, position.z, radius, sections: sections);

  void renderEditMode() {
    if (playMode) return;
    if (editor.gameObjectSelected.value){
      engine.renderCircleOutline(
        sides: 24,
        radius: 30,
        x: editor.gameObject.value!.renderX,
        y: editor.gameObject.value!.renderY,
        color: Colors.white,
      );
      renderCircleAtPosition(position: editor.gameObject.value!, radius: 50);
      return;
    }

    renderEditWireFrames();
    renderMouseWireFrame();
  }


  double getVolumeTargetWind() {
    final windLineDistance = (engine.screenCenterRenderX - windLineRenderX).abs();
    final windLineDistanceVolume = GameAudio.convertDistanceToVolume(windLineDistance, maxDistance: 300);
    var target = 0.0;
    if (windLineRenderX - 250 <= engine.screenCenterRenderX) {
      target += windLineDistanceVolume;
    }
    final index = windTypeAmbient.value;
    if (index <= WindType.Calm) {
      if (hours.value < 6) return target;
      if (hours.value < 18) return target + 0.1;
      return target;
    }
    if (index <= WindType.Gentle) return target + 0.5;
    return 1.0;
  }

  void emitLightAmbientShadows({
    required int index,
    required int alpha,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final padding = interpolationPadding;
    final rx = getIndexRenderX(index);
    if (rx < engine.Screen_Left - padding) return;
    if (rx > engine.Screen_Right + padding) return;
    final ry = getIndexRenderY(index);
    if (ry < engine.Screen_Top - padding) return;
    if (ry > engine.Screen_Bottom + padding) return;
    totalActiveLights++;

    final row = getIndexRow(index);
    final column = getIndexColumn(index);
    final z = getIndexZ(index);

    final nodeType = nodeTypes[index];
    final nodeOrientation = nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!isNodeTypeTransparent(nodeType)){
      if (const [
        NodeOrientation.Half_North,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vxStart = 0;
      }

      if (const [
        NodeOrientation.Half_South,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vxEnd = 0;
      }

      if (const [
        NodeOrientation.Half_East,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vyStart = 0;
      }

      if (const [
        NodeOrientation.Half_West,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vyEnd = 0;
      }
    }

    applyAmbient(
      index: index,
      alpha: alpha,
      interpolation: 0,
    );

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeAmbient(
            row: row,
            column: column,
            z: z,
            interpolation: -1,
            alpha: alpha,
            vx: vx,
            vy: vy,
            vz: vz,
          );
        }
      }
    }
  }

  void renderMouseWireFrame() {
    io.mouseRaycast(renderWireFrameBlue);
  }


  void playerAimTargetNameText(){
    if (player.aimTargetCategory == TargetCategory.Nothing)
      return;
    if (player.aimTargetName.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    engine.renderText(
      player.aimTargetName,
      engine.worldToScreenX(player.aimTargetPosition.renderX),
      engine.worldToScreenY(player.aimTargetPosition.renderY),
      style: style,
    );
  }

  void renderPlayerEnergy() {
    if (player.dead) return;
    if (!player.active.value) return;
    renderBarBlue(
      player.position.x,
      player.position.y,
      player.position.z,
      player.energyPercentage,
    );
  }

  void canvasRenderCursorCrossHair(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() - range,
        anchorY: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() + range,
        anchorY: 0.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() - range,
        dstY: io.getCursorScreenY(),
        anchorX: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY(),
        anchorX: 0.0
    );
  }

  void canvasRenderCursorCrossHairRed(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 0;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() - range,
        dstY: io.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  void canvasRenderCursorHand(ui.Canvas canvas){
    engine.renderExternalCanvas(
      canvas: canvas,
      image: Images.atlas_icons,
      srcX: 0,
      srcY: 256,
      srcWidth: 64,
      srcHeight: 64,
      dstX: io.getCursorScreenX(),
      dstY: io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void canvasRenderCursorTalk(ui.Canvas canvas){
    engine.renderExternalCanvas(
      canvas: canvas,
      image: Images.atlas_icons,
      srcX: 0,
      srcY: 320,
      srcWidth: 64,
      srcHeight: 64,
      dstX: io.getCursorScreenX(),
      dstY: io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void renderCursor(Canvas canvas) {
    final cooldown = player.weaponCooldown.value;
    final accuracy = player.accuracy.value;
    final distance = ((1.0 - cooldown) + (1.0 - accuracy)) * 10.0 + 5;

    switch (cursorType) {
      case IsometricCursorType.CrossHair_White:
        canvasRenderCursorCrossHair(canvas, distance);
        break;
      case IsometricCursorType.Hand:
        canvasRenderCursorHand(canvas);
        return;
      case IsometricCursorType.Talk:
        canvasRenderCursorTalk(canvas);
        return;
      case IsometricCursorType.CrossHair_Red:
        canvasRenderCursorCrossHairRed(canvas, distance);
        break;
    }
  }


  void renderBarBlue(double x, double y, double z, double percentage) {
    engine.renderSprite(
      image: Images.atlas_gameobjects,
      dstX: getRenderX(x, y, z) - 26,
      dstY: getRenderY(x, y, z) - 55,
      srcX: 171,
      srcY: 48,
      srcWidth: 51.0 * percentage,
      srcHeight: 8,
      anchorX: 0.0,
      color: 1,
    );
  }

  void renderMouseTargetName() {
    if (!player.mouseTargetAllie.value) return;
    final mouseTargetName = player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    renderText(
        text: mouseTargetName,
        x: player.aimTargetPosition.renderX,
        y: player.aimTargetPosition.renderY - 55);
  }

  void renderStarsV3(IsometricPosition v3) =>
      renderStars(v3.renderX, v3.renderY - 40);

  void renderStars(double x, double y) =>
      engine.renderSprite(
        image: Images.sprite_stars,
        srcX: 125.0 * animationFrame16,
        srcY: 0,
        srcWidth: 125,
        srcHeight: 125,
        dstX: x,
        dstY: y,
        scale: 0.4,
      );


  static double getPositionRenderX(IsometricPosition v3) => getRenderX(v3.x, v3.y, v3.z);

  static double getPositionRenderY(IsometricPosition v3) => getRenderY(v3.x, v3.y, v3.z);

  static double getRenderX(double x, double y, double z) => (x - y) * 0.5;

  static double getRenderY(double x, double y, double z) => ((x + y) * 0.5) - z;


}
