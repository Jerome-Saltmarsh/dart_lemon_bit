

import 'dart:math';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_gameobject.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_options.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'atlases/atlas_nodes.dart';
import 'classes/isometric_character.dart';
import 'classes/isometric_position.dart';
import 'classes/isometric_projectile.dart';
import 'components/functions/format_bytes.dart';
import 'components/render/renderer_characters.dart';
import 'enums/cursor_type.dart';
import 'enums/emission_type.dart';
import 'ui/game_isometric_minimap.dart';
import 'classes/isometric_particles.dart';
import 'components/render/renderer_gameobjects.dart';
import 'components/render/renderer_particles.dart';
import 'components/src.dart';
import 'ui/isometric_constants.dart';

class Isometric {

  final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  var nextEmissionSmoke = 0;
  var cursorType = IsometricCursorType.Hand;
  var srcXRainFalling = 6640.0;
  var srcXRainLanding = 6739.0;
  var messageStatusDuration = 0;
  var areaTypeVisibleDuration = 0;
  var nextLightingUpdate = 0;
  var totalActiveLights = 0;
  var interpolation_padding = 0.0;
  var torchEmissionStart = 0.8;
  var torchEmissionEnd = 1.0;
  var torchEmissionVal = 0.061;
  var torchEmissionT = 0.0;
  var nodesRaycast = 0;
  var windLine = 0;

  late final edit = Watch(false, onChanged: gamestream.isometric.onChangedEdit);
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
  late final rainType = Watch(RainType.None, onChanged: gamestream.isometric.onChangedRain);
  late final seconds = Watch(0, onChanged: gamestream.isometric.onChangedSeconds);
  late final hours = Watch(0, onChanged: gamestream.isometric.onChangedHour);
  late final windTypeAmbient = Watch(WindType.Calm, onChanged: gamestream.isometric.onChangedWindType);

  final gameObjects = <IsometricGameObject>[];

  final animation = IsometricAnimation();
  final debug = IsometricDebug();
  final scene = IsometricScene();
  final minimap = IsometricMinimap();
  final editor = IsometricEditor();
  final player = IsometricPlayer();
  final camera = IsometricCamera();
  final ui = IsometricUI();
  final options = IsometricOptions();

  var totalProjectiles = 0;
  final projectiles = <IsometricProjectile>[];
  late final particles = IsometricParticles(scene);
  late final renderer = IsometricRender(
    rendererGameObjects: RendererGameObjects(scene),
    rendererParticles: RendererParticles(scene, particles.particles),
    rendererCharacters: RendererCharacters(scene),
    rendererNodes: RendererNodes(scene),
    rendererProjectiles: RendererProjectiles(scene),
  );

  bool get playMode => !editMode;

  bool get editMode => edit.value;

  bool get lightningOn => gamestream.isometric.lightningType.value != LightningType.Off;


  void drawCanvas(Canvas canvas, Size size) {
    if (gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      // particles.updateParticles();
    }
    camera.update();
    renderer.render3D();
    renderer.renderEditMode();
    renderer.renderMouseTargetName();

    debug.render(renderer);

    gamestream.rendersSinceUpdate.value++;
  }

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

  void update(){
    if (!gameRunning.value) {
      gamestream.io.writeByte(ClientRequest.Update);
      gamestream.io.applyKeyboardInputToUpdateBuffer();
      gamestream.io.sendUpdateBuffer();
      return;
    }

    gamestream.audio.update();
    particles.updateParticles();
    animation.updateAnimationFrame();
    updateProjectiles();
    updateGameObjects();
    player.updateMessageTimer();
    readPlayerInputEdit();

    gamestream.io.applyKeyboardInputToUpdateBuffer();
    gamestream.io.sendUpdateBuffer();


    updateTorchEmissionIntensity();
    updateParticleEmitters();

    interpolation_padding = ((gamestream.isometric.scene.interpolationLength + 1) * Node_Size) / gamestream.engine.zoom;
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
    scene.characters.clear();
    projectiles.clear();
    gameObjects.clear();
    totalProjectiles = 0;
    scene.totalCharacters = 0;
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
          scene.applyVector3Emission(
            gameObject,
            hue: gameObject.emissionHue,
            saturation: gameObject.emissionSat,
            value: gameObject.emissionVal,
            alpha: gameObject.emissionAlp,
            intensity: gameObject.emission_intensity,
          );
          continue;
        case EmissionType.Ambient:
          scene.applyVector3EmissionAmbient(gameObject,
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
        gamestream.isometric.particles.spawnParticleSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
        gamestream.isometric.particles.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
      }
      if (projectile.type == ProjectileType.Orb) {
        gamestream.isometric.particles.spawnParticleOrbShard(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          angle: randomAngle(),
        );
      }
    }
  }

  void projectShadow(IsometricPosition v3){
    if (!gamestream.isometric.scene.inBoundsPosition(v3)) return;

    final z = getProjectionZ(v3);
    if (z < 0) return;
    gamestream.isometric.particles.spawnParticle(
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
      final nodeIndex = gamestream.isometric.scene.getIndexXYZ(x, y, z);
      final nodeOrientation = gamestream.isometric.scene.nodeOrientations[nodeIndex];

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
    gamestream.isometric.scene.colorStackIndex = -1;
    gamestream.isometric.scene.ambientStackIndex = -1;
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
    gamestream.isometric.scene.applyEmissionsLightSources();
    gamestream.isometric.scene.applyEmissionsCharacters();
    gamestream.isometric.applyEmissionGameObjects();
    applyEmissionsProjectiles();
    applyCharacterColors();
    gamestream.isometric.particles.applyEmissionsParticles();

    applyEmissionEditorSelectedNode();
  }

  void applyEmissionEditorSelectedNode() {
    if (!editMode) return;
    if ((gamestream.isometric.editor.gameObject.value == null || gamestream.isometric.editor.gameObject.value!.colorType == EmissionType.None)){
      gamestream.isometric.scene.emitLightAmbient(
        index: gamestream.isometric.editor.nodeSelectedIndex.value,
        // hue: gamestream.isometric.scene.ambientHue,
        // saturation: gamestream.isometric.scene.ambientSaturation,
        // value: gamestream.isometric.scene.ambientValue,
        alpha: 0,
      );
    }
  }

  void applyCharacterColors(){
    for (var i = 0; i < gamestream.isometric.scene.totalCharacters; i++){
      applyCharacterColor(gamestream.isometric.scene.characters[i]);
    }
  }

  void applyCharacterColor(IsometricCharacter character){
    character.color = gamestream.isometric.scene.getRenderColorPosition(character);
  }

  void applyEmissionsProjectiles() {
    for (var i = 0; i < gamestream.isometric.totalProjectiles; i++){
      applyProjectileEmission(gamestream.isometric.projectiles[i]);
    }
  }

  void applyProjectileEmission(IsometricProjectile projectile) {
    if (projectile.type == ProjectileType.Orb) {
      gamestream.isometric.scene.applyVector3Emission(projectile,
        hue: 100,
        saturation: 1,
        value: 1,
        alpha: 20,
      );
      return;
    }
    if (projectile.type == ProjectileType.Bullet) {
      gamestream.isometric.scene.applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
    if (projectile.type == ProjectileType.Fireball) {
      gamestream.isometric.scene.applyVector3Emission(projectile,
        hue: 167,
        alpha: 50,
        saturation: 1,
        value: 1,
      );
      return;
    }
    if (projectile.type == ProjectileType.Arrow) {
      gamestream.isometric.scene.applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
  }

  void clear() {
    gamestream.isometric.player.position.x = -1;
    gamestream.isometric.player.position.y = -1;
    gamestream.isometric.player.gameDialog.value = null;
    gamestream.isometric.player.npcTalkOptions.value = [];
    gamestream.isometric.totalProjectiles = 0;
    gamestream.isometric.particles.particles.clear();
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

    gamestream.isometric.scene.torch_emission_intensity = interpolateDouble(
      start: torchEmissionStart,
      end: torchEmissionEnd,
      t: torchEmissionT,
    );
  }

  void updateParticleEmitters(){
    nextEmissionSmoke--;
    if (nextEmissionSmoke > 0) return;
    nextEmissionSmoke = 20;
    final gameObjects = gamestream.isometric.gameObjects;
    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ObjectType.Barrel_Flaming) continue;
      gamestream.isometric.particles.spawnParticleSmoke(x: gameObject.x + giveOrTake(5), y: gameObject.y + giveOrTake(5), z: gameObject.z + 35);
    }
  }

  // PROPERTIES

  var _updateCredits = true;

  void updateCredits() {
    _updateCredits = !_updateCredits;
    if (!_updateCredits) return;
    final diff = playerCreditsAnimation.value - gamestream.isometric.player.credits.value;
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
    if (gamestream.isometric.lightningFlashing.value) return;
    const Seconds_Per_Hour = 3600;
    const Seconds_Per_Hours_12 = Seconds_Per_Hour * 12;
    final totalSeconds = (gamestream.isometric.hours.value * Seconds_Per_Hour) + (gamestream.isometric.minutes.value * 60);

    gamestream.isometric.scene.ambientAlpha = ((totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) * 255).round();

    if (gamestream.isometric.rainType.value == RainType.Light){
      gamestream.isometric.scene.ambientAlpha += 20;
    }
    if (gamestream.isometric.rainType.value == RainType.Heavy){
      gamestream.isometric.scene.ambientAlpha += 40;
    }
    gamestream.isometric.scene.resetNodeColorsToAmbient();
  }

  void refreshRain(){
    switch (gamestream.isometric.rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if (gamestream.isometric.windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if (gamestream.isometric.windTypeAmbient.value == WindType.Calm){
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
      gamestream.isometric.particles.spawnParticleConfetti(
        gamestream.isometric.player.position.x,
        gamestream.isometric.player.position.y,
        gamestream.isometric.player.position.z,
      );
    }
  }

  void playSoundWindow() =>
      gamestream.audio.click_sound_8(1);

  void messageClear(){
    writeMessage('');
  }

  void writeMessage(String value){
    gamestream.isometric.messageStatus.value = value;
  }

  void playAudioError(){
    gamestream.audio.errorSound15();
  }

  void onChangedAttributesWindowVisible(bool value){
    gamestream.isometric.playSoundWindow();
  }

  void onChangedRaining(bool raining){
    raining ? gamestream.isometric.scene.rainStart() : gamestream.isometric.scene.rainStop();
    gamestream.isometric.scene.resetNodeColorsToAmbient();
  }

  void onChangedMessageStatus(String value){
    if (value.isEmpty){
      gamestream.isometric.messageStatusDuration = 0;
    } else {
      gamestream.isometric.messageStatusDuration = 150;
    }
  }

  void onChangedAreaTypeVisible(bool value) =>
      gamestream.isometric.areaTypeVisibleDuration = value
          ? 150
          : 0;

  void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }
}