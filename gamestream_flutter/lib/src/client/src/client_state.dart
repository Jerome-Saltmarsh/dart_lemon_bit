
import 'dart:math';

import 'package:gamestream_flutter/library.dart';

/// The data stored in client state belongs to the client and can be safely read and written
class ClientState {
  // WATCHES
  static final sceneChanged = Watch(0);
  static final raining = Watch(false, onChanged: ClientEvents.onChangedRaining);
  static final areaTypeVisible = Watch(false, onChanged: ClientEvents.onChangedAreaTypeVisible);
  static final readsHotKeys = Watch(0);
  static final inventoryReads = Watch(0, onChanged: ClientEvents.onInventoryReadsChanged);
  static final hoverTargetType = Watch(ClientType.Hover_Target_None);
  static final hoverIndex = Watch(-1);
  static final hoverDialogType = Watch(DialogType.None);
  static final debugMode = Watch(false, onChanged: ClientEvents.onChangedDebugMode);
  static final Map_Visible = WatchBool(true);
  static final touchButtonSide = Watch(TouchButtonSide.Right);
  static final rendersSinceUpdate = Watch(0, onChanged: GameEvents.onChangedRendersSinceUpdate);
  static final edit = Watch(false, onChanged: GameEvents.onChangedEdit);
  static final dragStart = Watch(-1);
  static final dragEnd = Watch(-1);
  static final messageStatus = Watch("", onChanged: ClientEvents.onChangedMessageStatus);
  static final overrideColor = WatchBool(false);

  static final window_visible_settings = WatchBool(false);
  static final window_visible_perks = WatchBool(false);
  static final window_visible_items = WatchBool(false);
  static final window_visible_menu = WatchBool(false);

  static final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  static final itemGroup = Watch(ItemGroup.Primary_Weapon);

  static final mouseOverItemType = Watch(-1);

  static final buff_active_infinite_ammo  = Watch(false);
  static final buff_active_double_damage  = Watch(false);
  static final buff_active_fast           = Watch(false);
  static final buff_active_invincible     = Watch(false);
  static final buff_active_no_recoil      = Watch(false);

  static final particles = <Particle>[];

  static var totalParticles = 0;
  static var totalActiveParticles = 0;
  static var srcXRainFalling = 6640.0;
  static var srcXRainLanding = 6739.0;
  static var messageStatusDuration = 0;
  static var areaTypeVisibleDuration = 0;

  static var nodesLightSources = Uint16List(0);
  static var nodesLightSourcesTotal = 0;
  static var nextLightingUpdate = 0;
  static var lights_active = 0;
  static var interpolation_padding = 0.0;

  static final playerCreditsAnimation = Watch(0, onChanged: ClientEvents.onChangedCredits);

  static DateTime? timeConnectionEstablished;

  // PROPERTIES
  static bool get hoverDialogIsInventory => hoverDialogType.value == DialogType.Inventory;
  static bool get hoverDialogDialogIsTrade => hoverDialogType.value == DialogType.Trade;

  static void update(){
    interpolation_padding = ((GameNodes.interpolation_length + 1) * Node_Size) / Engine.zoom;
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

  static var _updateCredits = true;

  static void updateCredits() {
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



  static void updateGameLighting(){
    if (overrideColor.value) return;
    if (ServerState.lightningFlashing.value) return;
    const Seconds_Per_Hour = 3600;
    const Seconds_Per_Hours_12 = Seconds_Per_Hour * 12;
    final totalSeconds = (ServerState.hours.value * Seconds_Per_Hour) + (ServerState.minutes.value * 60);

    GameNodes.ambient_alp = ((totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) * 255).round();

    if (ServerState.rainType.value == RainType.Light){
      GameNodes.ambient_alp += 20;
    }
    if (ServerState.rainType.value == RainType.Heavy){
      GameNodes.ambient_alp += 40;
    }
    GameNodes.resetNodeColorsToAmbient();
  }

  static void countTotalActiveParticles(){
    totalActiveParticles = 0;
    totalParticles = particles.length;
    for (; totalActiveParticles < totalParticles; totalActiveParticles++){
      if (!particles[totalActiveParticles].active) break;
    }
  }


  static void sortParticles() {
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

  static bool compareRenderOrder(Vector3 a, Vector3 b) {
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

  static void sortParticlesActive(){
    var total = particles.length;
    ClientState.totalParticles = total;

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

  static bool verifyTotalActiveParticles() =>
      countActiveParticles() == totalActiveParticles;

  static int countActiveParticles(){
    var active = 0;
    for (var i = 0; i < particles.length; i++){
      if (particles[i].active)
        active++;
    }
    return active;
  }

  /// This may be the cause of the bug in which the sword particle does not render
  static Particle getInstanceParticle() {
    totalActiveParticles++;
    if (totalActiveParticles >= totalParticles){
      final instance = Particle();
      particles.add(instance);
      return instance;
    }
    return particles[totalActiveParticles];
  }

  static void refreshRain(){
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

  static void applyEmissionsParticles() {
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      final particle = particles[i];
      if (!particle.active) continue;
      if (particle.type != ParticleType.Light_Emission) continue;
      GameNodes.emitLightAHSVShadowed(
        index: particle.nodeIndex,
        hue: particle.lightHue,
        saturation: particle.lightSaturation,
        value: particle.lightValue,
        alpha: particle.alpha,
      );
    }
  }

  static Duration? get connectionDuration {
    if (timeConnectionEstablished == null) return null;
    return DateTime.now().difference(timeConnectionEstablished!);
  }

  static String get formattedConnectionDuration {
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return 'minutes: $minutes, seconds: $seconds';
  }

  static String formatAverageBufferSize(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds;
    final bytesPerSecond = (bytes / seconds).round();
    final bytesPerMinute = bytesPerSecond * 60;
    final bytesPerHour = bytesPerMinute * 60;
    return 'per second: $bytesPerSecond, per minute: $bytesPerMinute, per hour: $bytesPerHour';
  }

  static String formatAverageBytePerSecond(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round());
  }

  static String formatAverageBytePerMinute(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 60);
  }

  static String formatAverageBytePerHour(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 3600);
  }

  static void clearParticles(){
    particles.clear();
    totalActiveParticles = 0;
    totalParticles = 0;
  }
}