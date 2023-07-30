
import 'dart:async';
import 'dart:math';
import 'dart:ui' as dartUI;

import 'package:archive/archive.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/functions/convert_seconds_to_ambient_alpha.dart';
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/lemon_bits.dart';
import 'package:gamestream_flutter/gamestream/audio/audio_single.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/games.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_response_reader.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_read_response.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/lemon_websocket_client/connection_status.dart';
import 'package:gamestream_flutter/lemon_websocket_client/convert_http_to_wss.dart';
import 'package:gamestream_flutter/lemon_websocket_client/websocket_client.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';

import '../network/functions/detect_connection_region.dart';
import 'atlases/atlas.dart';
import 'atlases/atlas_nodes.dart';
import 'classes/src.dart';
import 'components/isometric_options.dart';
import 'components/render/classes/template_animation.dart';
import 'components/src.dart';
import 'enums/cursor_type.dart';
import 'enums/emission_type.dart';
import 'ui/game_isometric_minimap.dart';
import 'ui/isometric_constants.dart';


class Isometric with ByteReader {

  Isometric() {
    print('Isometric()');
    network = WebsocketClient(
      readString: readNetworkString,
      readBytes: readNetworkBytes,
      onError: onError,
    );
    network.connectionStatus.onChanged(onChangedNetworkConnectionStatus);
    particles = IsometricParticles(this);
    audio = GameAudio(this);
    editor = IsometricEditor(this);
    debug = IsometricDebug(this);
    minimap = IsometricMinimap(this);
    camera = IsometricCamera(this);
    mouse = IsometricMouse(this);
    player = IsometricPlayer(this);
    ui = IsometricUI(this);
    games = Games(this);

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

  late final Games games;
  late final WebsocketClient network;
  late final IsometricParticles particles;
  late final GameAudio audio;
  late final IsometricDebug debug;
  late final IsometricEditor editor;
  late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricPlayer player;
  late final IsometricUI ui;

  final characters = <Character>[];

  var totalCharacters = 0;

  var framesPerSmokeEmission = 10;

  var updateAmbientAlphaAccordingToTimeEnabled = true;

  var bakeStackRecording = true;

  var bakeStackTotal = 0;

  var bakeStackIndex = Uint16List(100000);

  var bakeStackBrightness = Uint8ClampedList(100000);

  var bakeStackStartIndex = Uint16List(10000);

  var bakeStackTorchIndex = Uint16List(10000);

  var bakeStackTorchSize = Uint16List(10000);

  var bakeStackTorchTotal = 0;

  var totalAmbientOffscreen = 0;

  var totalAmbientOnscreen = 0;

  var renderResponse = true;

  var renderCursorEnable = true;

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

  var nodesRaycast = 0;

  var windLine = 0;

  var totalProjectiles = 0;

  final scene = IsometricScene();

  final lighting = Lighting();

  final colors = IsometricColors();

  final decoder = ZLibDecoder();

  final imagesLoadedCompleted = Completer();

  final textEditingControllerMessage = TextEditingController();

  final textFieldMessage = FocusNode();

  final panelTypeKey = <int, GlobalKey>{};

  final playerTextStyle = TextStyle(color: Colors.white);

  final timeVisible = Watch(true);

  final windowOpenMenu = WatchBool(false);

  final operationStatus = Watch(OperationStatus.None);

  final region = Watch<ConnectionRegion?>(ConnectionRegion.LocalHost);

  final serverFPS = Watch(0);

  final images = Images();

  final options = IsometricOptions();

  final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  final imagesLoaded = Future.value(false);

  final playerExperiencePercentage = Watch(0.0);

  final sceneEditable = Watch(false);

  final sceneName = Watch<String?>(null);

  final gameRunning = Watch(true);

  final weatherBreeze = Watch(false);

  final minutes = Watch(0);

  final lightningType = Watch(LightningType.Off);

  final watchTimePassing = Watch(false);

  final sceneUnderground = Watch(false);

  final gameObjects = <GameObject>[];

  final projectiles = <Projectile>[];

  final animation = IsometricAnimation();

  late final Map<int, dartUI.Image> mapGameObjectTypeToImage;

  late final messageBoxVisible = Watch(false, clamp: (bool value) {
    return value;
  }, onChanged: ui.onVisibilityChangedMessageBox);

  late final edit = Watch(false, onChanged:  onChangedEdit);

  late final messageStatus = Watch('', onChanged: onChangedMessageStatus);

  late final raining = Watch(false, onChanged: onChangedRaining);

  late final areaTypeVisible = Watch(false, onChanged: onChangedAreaTypeVisible);

  late final gameTimeEnabled = Watch(false, onChanged: onChangedGameTimeEnabled);

  late final lightningFlashing = Watch(false, onChanged: onChangedLightningFlashing);

  late final rainType = Watch(RainType.None, onChanged:  onChangedRain);

  late final seconds = Watch(0, onChanged:  onChangedSeconds);

  late final hours = Watch(0, onChanged:  onChangedHour);

  late final windTypeAmbient = Watch(WindType.Calm, onChanged:  onChangedWindType);

  late final error = Watch<GameError?>(null, onChanged: _onChangedGameError);

  late final account = Watch<Account?>(null, onChanged: onChangedAccount);

  late final gameType = Watch(GameType.Website, onChanged: onChangedGameType);

  late final game = Watch<Game>(games.website, onChanged: _onChangedGame);

  late final io = GameIO(this);

  late final rendersSinceUpdate = Watch(0, onChanged: onChangedRendersSinceUpdate);

  late final Engine engine;

  late final IsometricRender render;

  bool get playMode => !editMode;

  bool get editMode => edit.value;

  bool get lightningOn =>  lightningType.value != LightningType.Off;

  double get windLineRenderX {
    var windLineColumn = 0;
    var windLineRow = 0;
    if (windLine < scene.totalRows){
      windLineColumn = 0;
      windLineRow =  scene.totalRows - windLine - 1;
    } else {
      windLineRow = 0;
      windLineColumn = windLine - scene.totalRows + 1;
    }
    return (windLineRow - windLineColumn) * Node_Size_Half;
  }

  void drawCanvas(Canvas canvas, Size size) {
    if (gameType.value == GameType.Website)
      return;

    totalAmbientOffscreen = 0;
    totalAmbientOnscreen = 0;

    particles.update();
    scene.update();
    render.render3D();
    renderEditMode();
    renderMouseTargetName();
    debug.render();
    game.value.drawCanvas(canvas, size);
    rendersSinceUpdate.value++;
  }

  void update(){

    if (!network.connected)
      return;

    if (!gameRunning.value) {
      io.writeByte(ClientRequest.Update);
      io.applyKeyboardInputToUpdateBuffer(this);
      io.sendUpdateBuffer();
      return;
    }

    updateClearErrorTimer();
    game.value.update();

    camera.update();
    audio.update();
    particles.update();
    animation.update();
    player.update();
    lighting.update();

    updateProjectiles();
    updateGameObjects();
    readPlayerInputEdit();

    io.applyKeyboardInputToUpdateBuffer(this);
    io.sendUpdateBuffer();

    updateParticleEmitters();

    interpolationPadding = ((scene.interpolationLength + 1) * Node_Size) / engine.zoom;
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
      updateAmbientAlphaAccordingToTime();
    }
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

  void selectGameObject(GameObject gameObject) =>
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

  GameObject findOrCreateGameObject(int id) {
    var instance = findGameObjectById(id);
    if (instance == null) {
      instance = GameObject(id);
      gameObjects.add(instance);
    }
    return instance;
  }

  GameObject? findGameObjectById(int id) {
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
          // TODO
          // emitLightColoredAtPosition(
          //   gameObject,
          //   hue: gameObject.emissionHue,
          //   saturation: gameObject.emissionSat,
          //   value: gameObject.emissionVal,
          //   alpha: gameObject.emissionAlp,
          //   intensity: gameObject.emissionIntensity,
          // );
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
        particles.emitSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
         spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
      }
      if (projectile.type == ProjectileType.Orb) {
        particles.spawnParticleOrbShard(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          angle: randomAngle(),
        );
      }
    }
  }

  void projectShadow(Position v3){
    if (!scene.inBoundsPosition(v3)) return;

    final z = getProjectionZ(v3);
    if (z < 0) return;
    particles.spawnParticle(
      type: ParticleType.Shadow,
      x: v3.x,
      y: v3.y,
      z: z,
      angle: 0,
      speed: 0,
      duration: 2,
    );
  }

  double getProjectionZ(Position vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;

    while (true) {
      if (z < 0) return -1;
      final nodeIndex =  scene.getIndexXYZ(x, y, z);
      final nodeOrientation =  scene.nodeOrientations[nodeIndex];

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
    scene.colorStackIndex = -1;
    scene.ambientStackIndex = -1;
  }

  void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      audio.thunder(1.0);
    } else {
      updateAmbientAlphaAccordingToTime();
    }
  }

  void onChangedGameTimeEnabled(bool value){
    timeVisible.value = value;
  }

  void applyEmissions(){
    totalActiveLights = 0;
    applyEmissionsScene();
    applyEmissionsCharacters();
    applyEmissionGameObjects();
    applyEmissionsProjectiles();
    applyEmissionsParticles();
    applyEmissionEditorSelectedNode();
    updateCharacterColors();
  }

  void applyEmissionsScene() {
    applyEmissionsColoredLightSources();
    if (bakeStackRecording){
      recordBakeStack();
    } else {
      applyEmissionBakeStack();
    }
  }

  void applyEmissionBakeStack() {

    final ambient = scene.ambientAlpha;

    final alpha = interpolate(
      ambient,
      0,
      lighting.torchEmissionIntensityAmbient,
    ).toInt();

    for (var i = 0; i < bakeStackTorchTotal; i++){
      final index = bakeStackTorchIndex[i];

      if (!indexOnscreen(index, padding: (Node_Size * 6)))
        continue;

      final start = bakeStackStartIndex[i];
      final size = bakeStackTorchSize[i];
      final end = start + size;

      for (var j = start; j < end; j++){
        final brightness = bakeStackBrightness[j];
        final index = bakeStackIndex[j];
        final intensity = brightness > 5 ? 1.0 : scene.interpolations[brightness];
        scene.applyAmbient(
          index: index,
          alpha: interpolate(ambient, alpha, intensity).toInt(),
        );
      }
    }
  }

  void applyEmissionEditorSelectedNode() {
    if (!editMode) return;
    if (( editor.gameObject.value == null ||  editor.gameObject.value!.colorType == EmissionType.None)){
       emitLightAmbient(
        index:  editor.nodeSelectedIndex.value,
        alpha: 0,
      );
    }
  }

  void updateCharacterColors(){
    for (var i = 0; i <  totalCharacters; i++){
      final character = characters[i];
      character.color =  scene.getRenderColorPosition(character);
    }
  }

  void applyEmissionsProjectiles() {
    for (var i = 0; i <  totalProjectiles; i++){
      applyProjectileEmission(projectiles[i]);
    }
  }

  void applyProjectileEmission(Projectile projectile) {
    if (projectile.type == ProjectileType.Orb) {
      //  emitLightColoredAtPosition(projectile,
      //   hue: 100,
      //   saturation: 1,
      //   value: 1,
      //   alpha: 20,
      // );
      return;
    }
    if (projectile.type == ProjectileType.Bullet) {
       applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
    if (projectile.type == ProjectileType.Fireball) {
      //  emitLightColoredAtPosition(projectile,
      //   hue: 167,
      //   alpha: 50,
      //   saturation: 1,
      //   value: 1,
      // );
      return;
    }
    if (projectile.type == ProjectileType.Arrow) {
       applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
    if (projectile.type == ProjectileType.FrostBall) {
      //  emitLightColoredAtPosition(
      //    projectile,
      //    hue: 203,
      //    saturation: 43,
      //    value: 100,
      //    alpha: 80,
      //
      // );
      return;
    }
  }

  void clear() {
     player.position.x = -1;
     player.position.y = -1;
     player.gameDialog.value = null;
     player.npcTalkOptions.value = [];
     totalProjectiles = 0;
     particles.particles.clear();
    engine.zoom = 1;
  }

  int get bodyPartDuration =>  randomInt(120, 200);

  void updateParticleEmitters(){
    if (nextEmissionSmoke-- > 0)
      return;

    nextEmissionSmoke = framesPerSmokeEmission;

    for (var i = 0; i < scene.smokeSourcesTotal; i++){
      final index = scene.smokeSources[i];
      particles.emitSmoke(
          x: scene.getIndexPositionX(index),
          y: scene.getIndexPositionY(index),
          z: scene.getIndexPositionZ(index),
          duration: 250,
      );
    }

    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ObjectType.Barrel_Flaming) continue;
      particles.emitSmoke(
          x: gameObject.x + giveOrTake(5),
          y: gameObject.y + giveOrTake(5),
          z: gameObject.z + 35,
      );
    }
  }

  // PROPERTIES
  int get currentTimeInSeconds => (hours.value * Duration.secondsPerHour) + ( minutes.value * 60);

  void updateAmbientAlphaAccordingToTime(){
    if (!updateAmbientAlphaAccordingToTimeEnabled)
      return;

    scene.ambientAlpha = convertSecondsToAmbientAlpha(currentTimeInSeconds);

    if (rainType.value == RainType.Light){
      scene.ambientAlpha += lighting.rainAmbienceLight;
    }
    if ( rainType.value == RainType.Heavy){
      scene.ambientAlpha += lighting.rainAmbientHeavy;
    }
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
      particles.spawnParticleConfetti(
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
    raining ?  scene.rainStart() :  scene.rainStop();
    scene.resetNodeColorsToAmbient();
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

  Particle spawnParticleFire({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0
  }) =>
      particles.spawnParticle(
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
        ..emissionColor = scene.ambientColor
        ..deactiveOnNodeCollision = false
        ..emissionIntensity = 0.5
  ;

  void spawnParticleLightEmissionAmbient({
    required double x,
    required double y,
    required double z,
  }) =>
      particles.spawnParticle(
        type: ParticleType.Light_Emission,
        x: x,
        y: y,
        z: z,
        angle: 0,
        speed: 0,
        weight: 0,
        duration: 35,
        animation: true,
      )
        ..flash = true
        ..emissionColor = scene.ambientColor
        ..emissionIntensity = 0.0
  ;

  // @override
  void readServerResponse(int serverResponse){
    rendersSinceUpdate.value = 0;

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
      case ServerResponse.Sort_GameObjects:
        gameObjects.sort();
        break;
      default:
        print('read error; index: $index');
        print(values);
        network.disconnect();
        return;
    }
  }

  // @override
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

  // @override
  void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
    print('isometric.onChangedNetworkConnectionStatus($connection)');
    bufferSize.value = 0;

    switch (connection) {
      case ConnectionStatus.Connected:
        engine.cursorType.value = CursorType.None;
        engine.zoomOnScroll = true;
        engine.zoom = 1.0;
        engine.targetZoom = 1.0;
        network.timeConnectionEstablished = DateTime.now();
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
        network.timeConnectionEstablished = null;
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
    scene.nodeTypes[nodeIndex] = nodeType;
    scene.nodeOrientations[nodeIndex] = nodeOrientation;
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
      projectiles.add(Projectile());
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

  void readCharacterTemplate(Character character){

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

  void readIsometricPosition(Position value){
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
    engine.buildUI = game.buildUI;
    engine.onLeftClicked = game.onLeftClicked;
    engine.onRightClicked = game.onRightClicked;
    engine.onKeyPressed = game.onKeyPressed;
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
        network.disconnect();
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

  void doRenderForeground(Canvas canvas, Size size){
    if (!network.connected)
      return;
    renderCursor(canvas);
    renderPlayerAimTargetNameText();

    if (io.inputModeTouch) {
      io.touchController.render(canvas);
    }

    game.value.renderForeground(canvas, size);
  }

  Future init(sharedPreferences) async {
    print('isometric.init()');
    images.load(this);
    await imagesLoadedCompleted.future;
  }

  void onMouseEnterCanvas(){
    renderCursorEnable = true;
  }

  void onMouseExitCanvas(){
    renderCursorEnable = false;
  }

  var initialized = false;

  Widget build(BuildContext context) {
    print('isometric.build()');

    if (initialized){
      print('isometric.build already initialized - skipping');
      return engine;
    }

    initialized = true;

    print('uri-base-host: ${Uri.base.host}');
    print('region-detected: ${detectConnectionRegion()}');

    engine = Engine(
      init: init,
      update: update,
      render: drawCanvas,
      onDrawForeground: doRenderForeground,
      title: 'AMULET',
      themeData: ThemeData(fontFamily: 'VT323-Regular'),
      backgroundColor: IsometricColors.black,
      onError: onError,
      buildUI: games.website.buildUI,
      buildLoadingScreen: buildLoadingPage,
    );

    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
    engine.drawCanvasAfterUpdate = true;
    engine.cursorType.value = CursorType.Basic;
    engine.deviceType.onChanged(onDeviceTypeChanged);
    engine.onScreenSizeChanged = onScreenSizeChanged;
    engine.onMouseEnterCanvas = onMouseEnterCanvas;
    engine.onMouseExitCanvas = onMouseExitCanvas;
    onEngineBuilt();
    return engine;
  }

  void onEngineBuilt(){
    print('isometric.onEngineBuilt()');
    render = IsometricRender(this);
  }

  Widget buildLoadingPage() {
    final totalImages = buildWatch(images.totalImages, buildText);
    final totalImagesLoaded = buildWatch(images.totalImagesLoaded, buildText);
    return Container(
      color: IsometricColors.black,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildText('Loading GameStream'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildText('Images '),
              totalImagesLoaded,
              buildText('/'),
              totalImages,

            ],
          )
        ],
      ),
    );
  }

  void onReadRespondFinished() {
    engine.onDrawCanvas = drawCanvas;

    if (renderResponse){
      engine.redrawCanvas();
    }
  }

  // FUNCTIONS
  void connectToRegion(ConnectionRegion region, String message) {
    print('isometric.connectToRegion(${region.name})');
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
    network.connect(uri: uri, message: '${ClientRequest.Join} $message');
  }

  void connectToGame(GameType gameType, [String message = '']) {
    final regionValue = region.value;
    if (regionValue == null) {
      throw Exception('region is null');
    }
    connectToRegion(regionValue, '${gameType.index} $message');
  }

  void sendClientRequest(int value, [dynamic message]) =>
      message != null ? network.send('${value} $message') : network.send(value);

  void detectInputMode() =>
      io.inputMode.value = engine.deviceIsComputer
          ? InputMode.Keyboard
          : InputMode.Touch;

  void playAudioSingleV3({
    required AudioSingle audioSingle,
    required Position position,
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

  void refreshGameObjectEmissionColor(GameObject gameObject){
    // TODO
    // gameObject.emissionColor = hsvToColor(
    //   hue: interpolate(ambientHue, gameObject.emissionHue, gameObject.emissionIntensity).toInt(),
    //   saturation: interpolate(ambientSaturation, gameObject.emissionSat, gameObject.emissionIntensity).toInt(),
    //   value: interpolate(ambientValue, gameObject.emissionVal, gameObject.emissionIntensity).toInt(),
    //   opacity: interpolate(ambientAlpha, gameObject.emissionAlp, gameObject.emissionIntensity).toInt(),
    // );
  }

  bool isOnscreen(Position position) {
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
    final length = particles.particles.length;
    for (var i = 0; i < length; i++) {
      final particle = particles.particles[i];
      if (!particle.active) continue;
      if (!particle.emitsLight) continue;
      emitLightColored(
        index: scene.getIndexPosition(particle),
        color: particle.emissionColor,
        intensity: particle.emissionIntensity,
      );
    }
  }

  void renderShadow(double x, double y, double z, {double scale = 1}) =>
      engine.renderSprite(
        image: images.atlas_gameobjects,
        dstX: (x - y) * 0.5,
        dstY: ((y + x) * 0.5) - z,
        srcX: 0,
        srcY: 32,
        srcWidth: 8,
        srcHeight: 8,
        scale: min(scale, 1),
      );

  bool isPerceptiblePosition(Position position) {
    if (!player.playerInsideIsland)
      return true;

    if (scene.outOfBoundsPosition(position))
      return false;

    final index = scene.getIndexPosition(position);
    final indexRow = scene.getIndexRow(index);
    final indexColumn = scene.getIndexRow(index);
    final i = indexRow * scene.totalColumns + indexColumn;
    // TODO REFACTOR
    if (!render.rendererNodes.island[i])
      return true;
    final indexZ = scene.getIndexZ(index);
    if (indexZ > player.indexZ + 2)
      return false;

    // TODO REFACTOR
    return render.rendererNodes.visible3D[index];
  }

  void applyEmissionsColoredLightSources() {
    for (var i = 0; i < scene.nodeLightSourcesTotal; i++){
      final nodeIndex = scene.nodeLightSources[i];
      final nodeType = scene.nodeTypes[nodeIndex];

      switch (nodeType) {
        case NodeType.Torch:
          break;
        case NodeType.Fireplace:
          emitLightColored(
            index: nodeIndex,
            color: colors.orange,
            intensity: lighting.torchEmissionIntensityColored,
          );
          break;
        case NodeType.Torch_Blue:
          emitLightColored(
            index: nodeIndex,
            color: colors.blue1,
            intensity: lighting.torchEmissionIntensityColored,
          );
          break;
        case NodeType.Torch_Red:
          emitLightColored(
            index: nodeIndex,
            color: colors.red1,
            intensity: lighting.torchEmissionIntensityColored,
          );
          break;
      }
    }
  }

  void recordBakeStack() {
    print('recordBakeStack()');
    bakeStackRecording = true;
    for (var i = 0; i < scene.nodeLightSourcesTotal; i++){
      final nodeIndex = scene.nodeLightSources[i];
      final nodeType = scene.nodeTypes[nodeIndex];
      final alpha = interpolate(
        scene.ambientAlpha,
        0,
        1.0,
      ).toInt();

      final currentSize = bakeStackTotal;

      switch (nodeType){
        case NodeType.Torch:
          emitLightAmbient(
            index: nodeIndex,
            alpha: alpha,
          );
          break;
      }

      bakeStackTorchIndex[bakeStackTorchTotal] = nodeIndex;
      bakeStackStartIndex[bakeStackTorchTotal] = currentSize;
      bakeStackTorchSize[bakeStackTorchTotal] = bakeStackTotal - currentSize;
      bakeStackTorchTotal++;
    }

    bakeStackRecording = false;
    print('recordBakeStack() finished recording total: ${bakeStackTotal}');
  }

  void applyVector3EmissionAmbient(Position v, {
    required int alpha,
    double intensity = 1.0,
  }){
    assert (intensity >= 0);
    assert (intensity <= 1);
    assert (alpha >= 0);
    assert (alpha <= 255);
    if (!scene.inBoundsPosition(v)) return;
    emitLightAmbient(
      index: scene.getIndexPosition(v),
      alpha: alpha,
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
      particles.spawnParticleFirePurple(
        x: x + giveOrTake(5),
        y: y + giveOrTake(5),
        z: z, speed: 1,
        angle: randomAngle(),
      );
    }

    // spawnParticleLightEmission(
    //   x: x,
    //   y: y,
    //   z: z,
    //   hue: 259,
    //   saturation: 45,
    //   value: 95,
    //   alpha: 0,
    // );
  }

  void emitLightColored({
    required int index,
    required int color,
    required double intensity,
  }){
    if (index < 0) return;
    if (index >= scene.totalNodes) return;

    final padding = interpolationPadding;
    final rx = scene.getIndexRenderX(index);
    if (rx < engine.Screen_Left - padding) return;
    if (rx > engine.Screen_Right + padding) return;
    final ry = scene.getIndexRenderY(index);
    if (ry < engine.Screen_Top - padding) return;
    if (ry > engine.Screen_Bottom + padding) return;
    totalActiveLights++;

    final row = scene.getIndexRow(index);
    final column = scene.getIndexColumn(index);
    final z = scene.getIndexZ(index);

    final nodeType = scene.nodeTypes[index];
    final nodeOrientation = scene.nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!scene.isNodeTypeTransparent(nodeType)){
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

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeColor(
            row: row,
            column: column,
            z: z,
            brightness: 7,
            vx: vx,
            vy: vy,
            vz: vz,
            color: color,
            intensity: intensity,
          );
        }
      }
    }
  }

  void shootLightTreeColor({
    required int row,
    required int column,
    required int z,
    required int brightness,
    required int color,
    required double intensity,
    int vx = 0,
    int vy = 0,
    int vz = 0,

  }){
    // assert (brightness < interpolationLength);
    var velocity = vx.abs() + vy.abs() + vz.abs();

    brightness -= velocity;
    if (brightness < 0) {
      return;
    }

    if (vx != 0) {
      row += vx;
      if (row < 0 || row >= scene.totalRows)
        return;
    }

    if (vy != 0) {
      column += vy;
      if (column < 0 || column >= scene.totalColumns)
        return;
    }

    if (vz != 0) {
      z += vz;
      if (z < 0 || z >= scene.totalZ)
        return;
    }

    const padding = Node_Size + Node_Size_Half;

    final index = (z * scene.area) + (row * scene.totalColumns) + column;

    final renderX = scene.getIndexRenderX(index);

    if (renderX < engine.Screen_Left - padding && (vx < 0 || vy > 0))
      return;

    if (renderX > engine.Screen_Right + padding && (vx > 0 || vy < 0))
      return;

    final renderY = scene.getIndexRenderY(index);

    if (renderY < engine.Screen_Top - padding && (vx < 0 || vy < 0 || vz > 0))
      return;

    if (renderY > engine.Screen_Bottom + padding && (vx > 0 || vy > 0))
      return;

    final nodeType = scene.nodeTypes[index];
    final nodeOrientation = scene.nodeOrientations[index];

    if (!scene.isNodeTypeTransparent(nodeType)) {
      if (nodeOrientation == NodeOrientation.Solid)
        return;

      if (vx < 0) {
        if (const [
          NodeOrientation.Half_South,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Slope_South,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_North,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Slope_North,
        ].contains(nodeOrientation)) vx = 0;
      } else if (vx > 0) {
        if (const [
          NodeOrientation.Half_North,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Slope_North,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_South,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Slope_South,
        ].contains(nodeOrientation)) vx = 0;
      }

      if (vy < 0) {
        if (const [
          NodeOrientation.Half_West,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Slope_West,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_East,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Slope_East,
        ].contains(nodeOrientation)) vy = 0;
      } else if (vy > 0) {
        if (const [
          NodeOrientation.Half_East,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Slope_East,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_West,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Slope_West,
        ].contains(nodeOrientation)) vy = 0;
      }

      if (vz < 0) {
        if (const [
          NodeOrientation.Half_Vertical_Bottom,
        ].contains(nodeOrientation)) {
          return;
        }

        if (const [
          NodeOrientation.Half_Vertical_Bottom,
          NodeOrientation.Half_Vertical_Center,
        ].contains(nodeOrientation)) {
          vz = 0;
        }
      }

      if (vz > 0) {
        if (const [NodeOrientation.Half_Vertical_Top]
            .contains(nodeOrientation)) {
          return;
        }

        if (const [
          NodeOrientation.Half_Vertical_Top,
          NodeOrientation.Half_Vertical_Center,
        ].contains(nodeOrientation)) {
          vz = 0;
        }
      }
    }

    scene.applyColor(
      index: index,
      intensity: (brightness > 5 ? 1.0 : scene.interpolations[brightness]) * intensity,
      color: color,
    );

    if (const [
      NodeType.Grass_Long,
      NodeType.Tree_Bottom,
      NodeType.Tree_Top,
    ].contains(nodeType)) {
      brightness--;
      if (brightness >= scene.interpolationLength)
        return;
    }

    velocity = vx.abs() + vy.abs() + vz.abs();

    if (velocity == 0)
      return;

    if (vx.abs() + vy.abs() + vz.abs() == 3) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: vy,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

    if (vx.abs() + vy.abs() == 2) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: vy,
        vz: 0,
        color: color,
        intensity: intensity,
      );
    }

    if (vx.abs() + vz.abs() == 2) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: 0,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

    if (vy.abs() + vz.abs() == 2) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: 0,
        vy: vy,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

    if (vy != 0) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: 0,
        vy: vy,
        vz: 0,
        color: color,
        intensity: intensity,
      );
    }

    if (vx != 0) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: 0,
        vz: 0,
        color: color,
        intensity: intensity,
      );
    }

    if (vz != 0) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: 0,
        vy: 0,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

  }

  /// @hue a number between 0 and 360
  /// @saturation a number between 0 and 100
  /// @value a number between 0 and 100
  /// @alpha a number between 0 and 255
  /// @intensity a number between 0.0 and 1.0
  void emitLightColoredAtPosition(Position v, {
    required int color,
    double intensity = 1.0,
  }){
    if (!scene.inBoundsPosition(v)) return;
    emitLightColored(
      index: scene.getIndexPosition(v),
      color: color,
      intensity: intensity,
    );
  }

  void renderLine(double x1, double y1, double z1, double x2, double y2, double z2) =>
      engine.renderLine(
        getRenderX(x1, y1, z1),
        getRenderY(x1, y1, z1),
        getRenderX(x2, y2, z2),
        getRenderY(x2, y2, z2),
      );

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
    required Position position,
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

    render.renderEditWireFrames();
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

  void emitLightAmbient({
    required int index,
    required int alpha,
  }){
    if (index < 0) return;
    if (index >= scene.totalNodes) return;

    if (!bakeStackRecording){
      final padding = interpolationPadding;
      final rx = scene.getIndexRenderX(index);
      if (rx < engine.Screen_Left - padding) return;
      if (rx > engine.Screen_Right + padding) return;
      final ry = scene.getIndexRenderY(index);
      if (ry < engine.Screen_Top - padding) return;
      if (ry > engine.Screen_Bottom + padding) return;
    }

    totalActiveLights++;

    final row = scene.getIndexRow(index);
    final column = scene.getIndexColumn(index);
    final z = scene.getIndexZ(index);

    final nodeType = scene.nodeTypes[index];
    final nodeOrientation = scene.nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!scene.isNodeTypeTransparent(nodeType)){
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

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeAmbient(
            row: row,
            column: column,
            z: z,
            brightness: 7,
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
    io.mouseRaycast(render.renderWireFrameBlue);
  }

  void renderPlayerAimTargetNameText(){
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

  void canvasRenderCursorCrossHair(Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
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
        image: images.atlas_icons,
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
        image: images.atlas_icons,
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
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY(),
        anchorX: 0.0
    );
  }

  void canvasRenderCursorCrossHairRed(Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 0;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
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
        image: images.atlas_icons,
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
        image: images.atlas_icons,
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
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  void canvasRenderCursorHand(Canvas canvas){
    engine.renderExternalCanvas(
      canvas: canvas,
      image: images.atlas_icons,
      srcX: 0,
      srcY: 256,
      srcWidth: 64,
      srcHeight: 64,
      dstX: io.getCursorScreenX(),
      dstY: io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void canvasRenderCursorTalk(Canvas canvas){
    engine.renderExternalCanvas(
      canvas: canvas,
      image: images.atlas_icons,
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

    if (!renderCursorEnable)
      return;

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

  void renderMouseTargetName() {
    if (!player.mouseTargetAllie.value) return;
    final mouseTargetName = player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    render.renderText(
        text: mouseTargetName,
        x: player.aimTargetPosition.renderX,
        y: player.aimTargetPosition.renderY - 55);
  }

  void renderStarsV3(Position v3) =>
      renderStars(v3.renderX, v3.renderY - 40);

  void renderStars(double x, double y) =>
      engine.renderSprite(
        image: images.sprite_stars,
        srcX: 125.0 * animation.frame16,
        srcY: 0,
        srcWidth: 125,
        srcHeight: 125,
        dstX: x,
        dstY: y,
        scale: 0.4,
      );

  void notifyLoadImagesCompleted() {
    print('isometric.notifyLoadImagesCompleted()');
    render.rendererNodes.atlasNodes = images.atlas_nodes;
    render.rendererNodes.atlasNodesLoaded = true;
    imagesLoadedCompleted.complete(true);

    mapGameObjectTypeToImage = <int, dartUI.Image> {
      GameObjectType.Weapon: images.atlas_weapons,
      GameObjectType.Object: images.atlas_gameobjects,
      GameObjectType.Head: images.atlas_head,
      GameObjectType.Body: images.atlas_body,
      GameObjectType.Legs: images.atlas_legs,
      GameObjectType.Item: images.atlas_items,
    };
  }

  Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }

  dartUI.Image getImageForGameObjectType(int type) =>
      mapGameObjectTypeToImage [type] ?? (
          throw Exception(
              'isometric.getImageForGameObjectType(type: ${GameObjectType.getName(type)}})'
          )
      );

  void readNetworkString(String value){

  }

  final bufferSize = Watch(0);

  void readNetworkBytes(Uint8List bytes) {
    assert (bytes.isNotEmpty);
    index = 0;
    this.values = bytes;
    bufferSize.value = bytes.length;
    final length = bytes.length;

    while (index < length) {
      readServerResponse(readByte());
    }

    onReadRespondFinished();
    index = 0;
  }



}
