
import 'dart:math';

import 'package:gamestream_flutter/library.dart';

/// The data stored in client state belongs to the client and can be safely read and written
class GameIsometricClientState2 {
  // WATCHES
  final sceneChanged = Watch(0);
  final raining = Watch(false, onChanged: ClientEvents.onChangedRaining);
  final areaTypeVisible = Watch(false, onChanged: ClientEvents.onChangedAreaTypeVisible);
  final readsHotKeys = Watch(0);
  final inventoryReads = Watch(0, onChanged: ClientEvents.onInventoryReadsChanged);
  final hoverTargetType = Watch(ClientType.Hover_Target_None);
  final hoverIndex = Watch(-1);
  final hoverDialogType = Watch(DialogType.None);
  final debugMode = Watch(false, onChanged: ClientEvents.onChangedDebugMode);
  final Map_Visible = WatchBool(true);
  final touchButtonSide = Watch(TouchButtonSide.Right);
  final rendersSinceUpdate = Watch(0, onChanged: GameEvents.onChangedRendersSinceUpdate);
  final edit = Watch(false, onChanged: GameEvents.onChangedEdit);
  final dragStart = Watch(-1);
  final dragEnd = Watch(-1);
  final messageStatus = Watch("", onChanged: ClientEvents.onChangedMessageStatus);
  final overrideColor = WatchBool(false);

  final window_visible_light_settings  = WatchBool(false);
  final window_visible_menu            = WatchBool(false);
  final window_visible_player_creation = WatchBool(false);
  final window_visible_attributes      = WatchBool(false);

  final control_visible_player_weapons = WatchBool(false);
  final control_visible_player_power   = WatchBool(true);
  final control_visible_scoreboard     = WatchBool(false);
  final control_visible_respawn_timer  = WatchBool(false);

  final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  final itemGroup = Watch(ItemGroup.Primary_Weapon);

  final mouseOverItemType = Watch(-1);

  final buff_active_infinite_ammo  = Watch(false);
  final buff_active_double_damage  = Watch(false);
  final buff_active_fast           = Watch(false);
  final buff_active_invincible     = Watch(false);
  final buff_active_no_recoil      = Watch(false);

  final particles = <Particle>[];

  var totalParticles = 0;
  var totalActiveParticles = 0;
  var srcXRainFalling = 6640.0;
  var srcXRainLanding = 6739.0;
  var messageStatusDuration = 0;
  var areaTypeVisibleDuration = 0;

  var nodesLightSources = Uint16List(0);
  var nodesLightSourcesTotal = 0;
  var nextLightingUpdate = 0;
  var lights_active = 0;
  var interpolation_padding = 0.0;

  final playerCreditsAnimation = Watch(0, onChanged: ClientEvents.onChangedCredits);

  DateTime? timeConnectionEstablished;

  // PROPERTIES
  bool get hoverDialogIsInventory => hoverDialogType.value == DialogType.Inventory;
  bool get hoverDialogDialogIsTrade => hoverDialogType.value == DialogType.Trade;

  void update(){
    interpolation_padding = ((gamestream.games.isometric.nodes.interpolation_length + 1) * Node_Size) / engine.zoom;
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
      nextLightingUpdate = GameConstants.Frames_Per_Lighting_Update;
      updateGameLighting();
    }

    updateCredits();
  }

  var _updateCredits = true;

  void updateCredits() {
    _updateCredits = !_updateCredits;
    if (!_updateCredits) return;
    final diff = playerCreditsAnimation.value - ServerState.playerCredits.value;
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
    if (ServerState.lightningFlashing.value) return;
    const Seconds_Per_Hour = 3600;
    const Seconds_Per_Hours_12 = Seconds_Per_Hour * 12;
    final totalSeconds = (ServerState.hours.value * Seconds_Per_Hour) + (ServerState.minutes.value * 60);

    gamestream.games.isometric.nodes.ambient_alp = ((totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) * 255).round();

    if (ServerState.rainType.value == RainType.Light){
      gamestream.games.isometric.nodes.ambient_alp += 20;
    }
    if (ServerState.rainType.value == RainType.Heavy){
      gamestream.games.isometric.nodes.ambient_alp += 40;
    }
    gamestream.games.isometric.nodes.resetNodeColorsToAmbient();
  }

  void countTotalActiveParticles(){
    totalActiveParticles = 0;
    totalParticles = particles.length;
    for (; totalActiveParticles < totalParticles; totalActiveParticles++){
      if (!particles[totalActiveParticles].active) break;
    }
  }


  void sortParticles() {
    sortParticlesActive();
    countTotalActiveParticles();

    if (totalActiveParticles == 0) return;

    assert (verifyTotalActiveParticles());

    Engine.insertionSort(
      particles,
      compare: compareRenderOrder,
      end: totalActiveParticles,
    );
  }

  bool compareRenderOrder(Vector3 a, Vector3 b) {
    final aRowColumn = a.indexRow + a.indexColumn;
    final bRowColumn = b.indexRow + b.indexColumn;

    if (aRowColumn > bRowColumn) return false;
    if (aRowColumn < bRowColumn) return true;

    final aIndexZ = a.indexZ;
    final bIndexZ = b.indexZ;

    if (aIndexZ > bIndexZ) return false;
    if (aIndexZ < bIndexZ) return true;

    return a.sortOrder < b.sortOrder;
  }

  void sortParticlesActive(){
    var total = particles.length;
    totalParticles = total;

    for (var pos = 1; pos < total; pos++) {
      var min = 0;
      var max = pos;
      var element = particles[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (!particles[mid].active) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      particles.setRange(min + 1, pos + 1, particles, min);
      particles[min] = element;
    }
  }

  bool verifyTotalActiveParticles() =>
      countActiveParticles() == totalActiveParticles;

  int countActiveParticles(){
    var active = 0;
    for (var i = 0; i < particles.length; i++){
      if (particles[i].active)
        active++;
    }
    return active;
  }

  /// This may be the cause of the bug in which the sword particle does not render
  Particle getInstanceParticle() {
    totalActiveParticles++;
    if (totalActiveParticles >= totalParticles){
      final instance = Particle();
      particles.add(instance);
      return instance;
    }
    return particles[totalActiveParticles];
  }

  void refreshRain(){
    switch (ServerState.rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if (ServerState.windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if (ServerState.windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = 1900;
        } else {
          srcXRainFalling = 1606;
        }
        break;
    }
  }

  void applyEmissionsParticles() {
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      final particle = particles[i];
      if (!particle.active) continue;
      if (particle.type != ParticleType.Light_Emission) continue;
      gamestream.games.isometric.nodes.emitLightAHSVShadowed(
        index: particle.nodeIndex,
        hue: particle.lightHue,
        saturation: particle.lightSaturation,
        value: particle.lightValue,
        alpha: particle.alpha,
      );
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

  void clearParticles(){
    particles.clear();
    totalActiveParticles = 0;
    totalParticles = 0;
  }
}