

import 'dart:math';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'atlases/atlas_nodes.dart';
import 'classes/src.dart';
import 'components/isometric_options.dart';
import 'components/render/renderer_characters.dart';
import 'enums/cursor_type.dart';
import 'enums/emission_type.dart';
import 'mixins/src.dart';
import 'ui/game_isometric_minimap.dart';
import 'components/render/renderer_gameobjects.dart';
import 'components/render/renderer_particles.dart';
import 'components/src.dart';
import 'ui/isometric_constants.dart';

class Isometric with
    IsometricScene,
    IsometricCharacters,
    IsometricParticles,
    IsometricAnimation
{

  final triggerAlarmNoMessageReceivedFromServer = Watch(false);

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
  late final renderer = IsometricRender(
    rendererGameObjects: RendererGameObjects(this),
    rendererParticles: RendererParticles(this, particles),
    rendererCharacters: RendererCharacters(this),
    rendererNodes: RendererNodes(this),
    rendererProjectiles: RendererProjectiles(this),
  );

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
    renderer.render3D();
    renderer.renderEditMode();
    renderer.renderMouseTargetName();

    debug.render(renderer);

    gamestream.rendersSinceUpdate.value++;
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
    if (!gameRunning.value) {
      gamestream.io.writeByte(ClientRequest.Update);
      gamestream.io.applyKeyboardInputToUpdateBuffer();
      gamestream.io.sendUpdateBuffer();
      return;
    }

    gamestream.audio.update();
    updateParticles();
    updateAnimationFrame();
    updateProjectiles();
    updateGameObjects();
    player.updateMessageTimer();
    readPlayerInputEdit();

    gamestream.io.applyKeyboardInputToUpdateBuffer();
    gamestream.io.sendUpdateBuffer();


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
        final wind = gamestream.isometric.windTypeAmbient.value * 0.01;
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
}