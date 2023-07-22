import 'dart:math';

import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/library.dart';

import '../atlases/atlas_nodes.dart';
import '../enums/emission_type.dart';
import '../enums/touch_button_side.dart';
import '../classes/isometric_character.dart';
import '../classes/isometric_position.dart';
import '../classes/isometric_projectile.dart';
import 'functions/format_bytes.dart';


mixin class IsometricClient {
  final sceneChanged = Watch(0);
  final touchButtonSide = Watch(TouchButtonSide.Right);
  final overrideColor = WatchBool(false);
  final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  var cursorType = IsometricCursorType.Hand;
  var srcXRainFalling = 6640.0;
  var srcXRainLanding = 6739.0;
  var messageStatusDuration = 0;
  var areaTypeVisibleDuration = 0;
  var nextLightingUpdate = 0;
  var lights_active = 0;
  var interpolation_padding = 0.0;
  var torch_emission_start = 0.8;
  var torch_emission_end = 1.0;
  var torch_emission_vel = 0.061;
  var torch_emission_t = 0.0;
  var nodesRaycast = 0;
  var windLine = 0;

  DateTime? timeConnectionEstablished;

  late final edit = Watch(false, onChanged: gamestream.isometric.events.onChangedEdit);
  late final messageStatus = Watch('', onChanged: onChangedMessageStatus);
  late final raining = Watch(false, onChanged: onChangedRaining);
  late final areaTypeVisible = Watch(false, onChanged: onChangedAreaTypeVisible);
  late final playerCreditsAnimation = Watch(0, onChanged: onChangedCredits);

  final gridShadows = Watch(true, onChanged: (bool value){
    gamestream.isometric.scene.resetNodeColorsToAmbient();
  });

  bool get playMode => !editMode;
  bool get editMode => edit.value;
  bool get lightningOn => gamestream.isometric.server.lightningType.value != LightningType.Off;

  // ACTIONS

  void applyEmissions(){
    lights_active = 0;
    gamestream.isometric.scene.applyEmissionsLightSources();
    gamestream.isometric.scene.applyEmissionsCharacters();
    gamestream.isometric.server.applyEmissionGameObjects();
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
    for (var i = 0; i < gamestream.isometric.server.totalProjectiles; i++){
      applyProjectileEmission(gamestream.isometric.server.projectiles[i]);
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
    gamestream.isometric.server.totalProjectiles = 0;
    gamestream.isometric.particles.particles.clear();
    gamestream.engine.zoom = 1;
  }

  int get bodyPartDuration =>  randomInt(120, 200);

  void updateTorchEmissionIntensity(){
    if (torch_emission_vel == 0) return;
    torch_emission_t += torch_emission_vel;

    if (
    torch_emission_t < torch_emission_start ||
        torch_emission_t > torch_emission_end
    ) {
      torch_emission_t = clamp(torch_emission_t, torch_emission_start, torch_emission_end);
      torch_emission_vel = -torch_emission_vel;
    }

    gamestream.isometric.scene.torch_emission_intensity = interpolateDouble(
      start: torch_emission_start,
      end: torch_emission_end,
      t: torch_emission_t,
    );
  }

  void toggleShadows () => gridShadows.value = !gridShadows.value;

  var nextEmissionSmoke = 0;

  void updateParticleEmitters(){
    nextEmissionSmoke--;
    if (nextEmissionSmoke > 0) return;
    nextEmissionSmoke = 20;
    for (final gameObject in gamestream.isometric.server.gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ObjectType.Barrel_Flaming) continue;
      gamestream.isometric.particles.spawnParticleSmoke(x: gameObject.x + giveOrTake(5), y: gameObject.y + giveOrTake(5), z: gameObject.z + 35);
    }
  }

  // PROPERTIES

  void update(){
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
    if (gamestream.isometric.server.lightningFlashing.value) return;
    const Seconds_Per_Hour = 3600;
    const Seconds_Per_Hours_12 = Seconds_Per_Hour * 12;
    final totalSeconds = (gamestream.isometric.server.hours.value * Seconds_Per_Hour) + (gamestream.isometric.server.minutes.value * 60);

    gamestream.isometric.scene.ambientAlpha = ((totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) * 255).round();

    if (gamestream.isometric.server.rainType.value == RainType.Light){
      gamestream.isometric.scene.ambientAlpha += 20;
    }
    if (gamestream.isometric.server.rainType.value == RainType.Heavy){
      gamestream.isometric.scene.ambientAlpha += 40;
    }
    gamestream.isometric.scene.resetNodeColorsToAmbient();
  }

  void refreshRain(){
    switch (gamestream.isometric.server.rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if (gamestream.isometric.server.windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if (gamestream.isometric.server.windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = 1900;
        } else {
          srcXRainFalling = 1606;
        }
        break;
    }
  }

  Duration? get connectionDuration {
    if (timeConnectionEstablished == null) return null;
    return DateTime.now().difference(timeConnectionEstablished!);
  }

  String get formattedConnectionDuration {
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return 'minutes: $minutes, seconds: $seconds';
  }

  String formatAverageBufferSize(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds;
    final bytesPerSecond = (bytes / seconds).round();
    final bytesPerMinute = bytesPerSecond * 60;
    final bytesPerHour = bytesPerMinute * 60;
    return 'per second: $bytesPerSecond, per minute: $bytesPerMinute, per hour: $bytesPerHour';
  }

  String formatAverageBytePerSecond(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round());
  }

  String formatAverageBytePerMinute(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 60);
  }

  String formatAverageBytePerHour(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 3600);
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
    gamestream.isometric.client.messageStatus.value = value;
  }

   void playAudioError(){
    gamestream.audio.errorSound15();
  }

  void onChangedAttributesWindowVisible(bool value){
    gamestream.isometric.client.playSoundWindow();
  }

  void onChangedRaining(bool raining){
    raining ? gamestream.isometric.scene.rainStart() : gamestream.isometric.scene.rainStop();
    gamestream.isometric.scene.resetNodeColorsToAmbient();
  }

  void onChangedMessageStatus(String value){
    if (value.isEmpty){
      gamestream.isometric.client.messageStatusDuration = 0;
    } else {
      gamestream.isometric.client.messageStatusDuration = 150;
    }
  }

  void onChangedAreaTypeVisible(bool value) =>
      gamestream.isometric.client.areaTypeVisibleDuration = value
          ? 150
          : 0;

  void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }


}