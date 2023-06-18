import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_constants.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';
import 'package:gamestream_flutter/library.dart';

import '../atlases/atlas_nodes.dart';
import '../enums/emission_type.dart';
import '../enums/touch_button_side.dart';
import '../classes/isometric_character.dart';
import '../classes/isometric_position.dart';
import '../classes/isometric_projectile.dart';


mixin class IsometricClientState {
  final sceneChanged = Watch(0);
  final readsHotKeys = Watch(0);
  final Map_Visible = WatchBool(true);
  final touchButtonSide = Watch(TouchButtonSide.Right);
  final overrideColor = WatchBool(false);
  final window_visible_light_settings = WatchBool(false);
  final window_visible_menu = WatchBool(false);
  final window_visible_player_creation = WatchBool(false);
  final window_visible_attributes = WatchBool(false);
  final control_visible_player_weapons = WatchBool(false);
  final control_visible_player_power = WatchBool(true);
  final control_visible_scoreboard = WatchBool(false);
  final control_visible_respawn_timer = WatchBool(false);
  final triggerAlarmNoMessageReceivedFromServer = Watch(false);
  final mouseOverItemType = Watch(-1);
  final buff_active_infinite_ammo = Watch(false);
  final buff_active_double_damage = Watch(false);
  final buff_active_fast = Watch(false);
  final buff_active_invincible = Watch(false);
  final buff_active_no_recoil = Watch(false);

  var srcXRainFalling = 6640.0;
  var srcXRainLanding = 6739.0;
  var messageStatusDuration = 0;
  var areaTypeVisibleDuration = 0;
  var nextLightingUpdate = 0;
  var lights_active = 0;
  var interpolation_padding = 0.0;
  var dynamicShadows = true;
  var emissionAlphaCharacter = 50;
  var torch_emission_start = 0.8;
  var torch_emission_end = 1.0;
  var torch_emission_vel = 0.061;
  var torch_emission_t = 0.0;
  var nodesRaycast = 0;
  var windLine = 0;

  DateTime? timeConnectionEstablished;

  late final edit = Watch(false, onChanged: gamestream.isometric.events.onChangedEdit);
  late final messageStatus = Watch("", onChanged: onChangedMessageStatus);
  late final debugMode = Watch(false, onChanged: onChangedDebugMode);
  late final raining = Watch(false, onChanged: onChangedRaining);
  late final areaTypeVisible = Watch(false, onChanged: onChangedAreaTypeVisible);
  late final playerCreditsAnimation = Watch(0, onChanged: onChangedCredits);

  final gridShadows = Watch(true, onChanged: (bool value){
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
  });


  bool get playMode => !editMode;
  bool get editMode => edit.value;
  bool get lightningOn => gamestream.isometric.server.lightningType.value != LightningType.Off;

  // ACTIONS

  void applyEmissions(){
    lights_active = 0;
    gamestream.isometric.nodes.applyEmissionsLightSources();
    applyEmissionsCharacters();
    gamestream.isometric.server.applyEmissionGameObjects();
    applyEmissionsProjectiles();
    applyCharacterColors();
    gamestream.isometric.particles.applyEmissionsParticles();
    applyEmissionEditorSelectedNode();
  }

  void applyEmissionEditorSelectedNode() {
    if (!editMode) return;
    if ((gamestream.isometric.editor.gameObject.value == null || gamestream.isometric.editor.gameObject.value!.emission_type == IsometricEmissionType.None)){
      gamestream.isometric.nodes.emitLightAHSVShadowed(
        index: gamestream.isometric.editor.nodeSelectedIndex.value,
        hue: gamestream.isometric.nodes.ambient_hue,
        saturation: gamestream.isometric.nodes.ambient_sat,
        value: gamestream.isometric.nodes.ambient_val,
        alpha: 0,
      );
    }
  }

  void applyCharacterColors(){
    for (var i = 0; i < gamestream.isometric.server.totalCharacters; i++){
      applyCharacterColor(gamestream.isometric.server.characters[i]);
    }
  }

  void applyCharacterColor(IsometricCharacter character){
    character.color = gamestream.isometric.nodes.getV3RenderColor(character);
  }

  void applyEmissionsCharacters() {
    final serverState = gamestream.isometric.server;
    final characters = serverState.characters;
    for (var i = 0; i < serverState.totalCharacters; i++) {
      final character = characters[i];
      if (!character.allie) continue;

      if (character.weaponType == ItemType.Weapon_Melee_Staff){
        applyVector3Emission(
          character,
          alpha: 150,
          saturation: 100,
          value: 100,
          hue: 50,
        );
      } else {
        applyVector3EmissionAmbient(
          character,
          alpha: emissionAlphaCharacter,
        );
      }
    }
  }

  void applyEmissionsProjectiles() {
    for (var i = 0; i < gamestream.isometric.server.totalProjectiles; i++){
      applyProjectileEmission(gamestream.isometric.server.projectiles[i]);
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
    if (!gamestream.isometric.nodes.inBoundsVector3(v)) return;
    gamestream.isometric.nodes.emitLightAHSVShadowed(
      index: gamestream.isometric.nodes.getNodeIndexV3(v),
      hue: hue,
      saturation: saturation,
      value: value,
      alpha: alpha,
      intensity: intensity,
    );
  }

  /// @alpha a number between 0 and 255
  /// @intensity a number between 0.0 and 1.0
  void applyVector3EmissionAmbient(IsometricPosition v, {
    required int alpha,
    double intensity = 1.0,
  }){
    assert (intensity >= 0);
    assert (intensity <= 1);
    assert (alpha >= 0);
    assert (alpha <= 255);
    if (!gamestream.isometric.nodes.inBoundsVector3(v)) return;
    gamestream.isometric.nodes.emitLightAmbient(
      index: gamestream.isometric.nodes.getNodeIndexV3(v),
      alpha: Engine.linerInterpolationInt(gamestream.isometric.nodes.ambient_hue, alpha , intensity),
    );
  }

  void clear() {
    gamestream.isometric.player.position.x = -1;
    gamestream.isometric.player.position.y = -1;
    gamestream.isometric.player.gameDialog.value = null;
    gamestream.isometric.player.npcTalkOptions.value = [];
    gamestream.isometric.server.totalZombies = 0;
    gamestream.isometric.server.totalPlayers = 0;
    gamestream.isometric.server.totalProjectiles = 0;
    gamestream.isometric.server.totalNpcs = 0;
    gamestream.isometric.server.interactMode.value = InteractMode.None;
    gamestream.isometric.particles.particles.clear();
    engine.zoom = 1;
    engine.redrawCanvas();
  }

  int get bodyPartDuration =>  randomInt(120, 200);

  /// do this during the draw call so that particles are smoother

  void interpolatePlayer(){

    if (!gamestream.isometric.player.interpolating.value) return;
    if (gamestream.rendersSinceUpdate.value == 0) {
      return;
    }
    if (gamestream.rendersSinceUpdate.value != 1) return;

    final playerCharacter = gamestream.isometric.server.getPlayerCharacter();
    if (playerCharacter == null) return;
    final velocityX = gamestream.isometric.player.position.x - gamestream.isometric.player.previousPosition.x;
    final velocityY = gamestream.isometric.player.position.y - gamestream.isometric.player.previousPosition.y;
    final velocityZ = gamestream.isometric.player.position.z - gamestream.isometric.player.previousPosition.z;
    playerCharacter.x += velocityX;
    playerCharacter.y += velocityY;
    playerCharacter.z -= velocityZ;
  }

  void renderEditMode() {
    if (playMode) return;
    if (gamestream.isometric.editor.gameObjectSelected.value){
      engine.renderCircleOutline(
        sides: 24,
        radius: ItemType.getRadius(gamestream.isometric.editor.gameObjectSelectedType.value),
        x: gamestream.isometric.editor.gameObject.value!.renderX,
        y: gamestream.isometric.editor.gameObject.value!.renderY,
        color: Colors.white,
      );
      return renderCircleV3(gamestream.isometric.editor.gameObject.value!);
    }

    renderEditWireFrames();
    gamestream.isometric.renderer.renderMouseWireFrame();
  }

  void renderEditWireFrames() {
    for (var z = 0; z < gamestream.isometric.editor.z; z++) {
      gamestream.isometric.renderer.renderWireFrameBlue(z, gamestream.isometric.editor.row, gamestream.isometric.editor.column);
    }
    gamestream.isometric.renderer.renderWireFrameRed(gamestream.isometric.editor.row, gamestream.isometric.editor.column, gamestream.isometric.editor.z);
  }

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

    gamestream.isometric.nodes.torch_emission_intensity = interpolateDouble(
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
      if (gameObject.type != ItemType.GameObjects_Barrel_Flaming) continue;
      gamestream.isometric.particles.spawnParticleSmoke(x: gameObject.x + giveOrTake(5), y: gameObject.y + giveOrTake(5), z: gameObject.z + 35);
    }
  }

  // PROPERTIES

  void update(){
    interpolation_padding = ((gamestream.isometric.nodes.interpolation_length + 1) * Node_Size) / engine.zoom;
    if (areaTypeVisible.value) {
      if (areaTypeVisibleDuration-- <= 0) {
        areaTypeVisible.value = false;
      }
    }

    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = "";
      }
    }

    if (nextLightingUpdate-- <= 0){
      nextLightingUpdate = GameIsometricConstants.Frames_Per_Lighting_Update;
      updateGameLighting();
    }

    updateCredits();
  }

  var _updateCredits = true;

  void updateCredits() {
    _updateCredits = !_updateCredits;
    if (!_updateCredits) return;
    final diff = playerCreditsAnimation.value - gamestream.isometric.server.playerCredits.value;
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

    gamestream.isometric.nodes.ambient_alp = ((totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) * 255).round();

    if (gamestream.isometric.server.rainType.value == RainType.Light){
      gamestream.isometric.nodes.ambient_alp += 20;
    }
    if (gamestream.isometric.server.rainType.value == RainType.Heavy){
      gamestream.isometric.nodes.ambient_alp += 40;
    }
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
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

  static String formatBytes(int bytes){
    final kb = bytes ~/ 1000;
    final mb = kb ~/ 1000;
    return 'mb: $mb, kb: ${kb % 1000}';
  }


  void toggleDynamicShadows() => dynamicShadows = !dynamicShadows;
  void redrawHotKeys() => readsHotKeys.value++;

  void showMessage(String message){
    messageStatus.value = "";
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
    writeMessage("");
  }

   void writeMessage(String value){
    gamestream.isometric.clientState.messageStatus.value = value;
  }

   void playAudioError(){
    gamestream.audio.errorSound15();
  }

  void onChangedAttributesWindowVisible(bool value){
    gamestream.isometric.clientState.playSoundWindow();
  }

  void onChangedHotKeys(int value){
    gamestream.isometric.clientState.redrawHotKeys();
  }

  void onChangedRaining(bool raining){
    raining ? gamestream.isometric.actions.rainStart() : gamestream.isometric.actions.rainStop();
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
  }

  void onChangedMessageStatus(String value){
    if (value.isEmpty){
      gamestream.isometric.clientState.messageStatusDuration = 0;
    } else {
      gamestream.isometric.clientState.messageStatusDuration = 150;
    }
  }

  void onChangedAreaTypeVisible(bool value) =>
      gamestream.isometric.clientState.areaTypeVisibleDuration = value
          ? 150
          : 0;

  void onChangedDebugMode(bool value){
    gamestream.isometric.renderer.renderDebug = value;
  }

  void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }


}