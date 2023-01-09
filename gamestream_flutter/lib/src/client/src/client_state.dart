
import 'package:gamestream_flutter/library.dart';

/// The data stored in client state belongs to the client and can be safely read and written
class ClientState {
  // WATCHES
  static final sceneChanged = Watch(0);
  static final process = Watch(0);
  static final raining = Watch(false, onChanged: ClientEvents.onChangedRaining);
  static final areaTypeVisible = Watch(false, onChanged: ClientEvents.onChangedAreaTypeVisible);
  static final readsHotKeys = Watch(0);
  static final inventoryReads = Watch(0, onChanged: ClientEvents.onInventoryReadsChanged);
  static final hoverTargetType = Watch(ClientType.Hover_Target_None);
  static final hoverIndex = Watch(-1);
  static final hoverDialogType = Watch(DialogType.None);
  static final windowVisibleAttributes = Watch(false, onChanged: ClientEvents.onChangedAttributesWindowVisible);
  static final debugVisible = Watch(false);
  // static final torchesIgnited = Watch(true);
  static final touchButtonSide = Watch(TouchButtonSide.Right);
  static final rendersSinceUpdate = Watch(0, onChanged: GameEvents.onChangedRendersSinceUpdate);
  static final edit = Watch(false, onChanged: GameEvents.onChangedEdit);
  static final dragStart = Watch(-1);
  static final dragEnd = Watch(-1);
  static final messageStatus = Watch("", onChanged: ClientEvents.onChangedMessageStatus);
  static final overrideColor = WatchBool(false);

  static final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  static final particles = <Particle>[];

  static var totalParticles = 0;
  static var totalActiveParticles = 0;
  static var showAllItems = false;
  static var srcXRainFalling = 6640.0;
  static var srcXRainLanding = 6739.0;
  static var messageStatusDuration = 0;
  static var areaTypeVisibleDuration = 0;

  static var nodesLightSources = Uint16List(0);
  static var nodesLightSourcesTotal = 0;
  static var nextLightingUpdate = 0;

  // PROPERTIES
  static bool get hoverDialogIsInventory => hoverDialogType.value == DialogType.Inventory;
  static bool get hoverDialogDialogIsTrade => hoverDialogType.value == DialogType.Trade;

  static void update(){

    process.value = 0;

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
  }

  static void updateGameLighting(){
    if (overrideColor.value) return;
    if (ServerState.lightningFlashing.value) return;
    const Seconds_Per_Hour = 3600;
    const Seconds_Per_Hours_12 = Seconds_Per_Hour * 12;
    final totalSeconds = (ServerState.hours.value * Seconds_Per_Hour) + (ServerState.minutes.value * 60);

    GameNodes.ambient_alp = totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12;

    if (ServerState.rainType.value == RainType.Light){
      GameNodes.ambient_alp += 0.1;
    }
    if (ServerState.rainType.value == RainType.Heavy){
      GameNodes.ambient_alp += 0.2;
    }
    GameNodes.resetNodeColorsToAmbient();
  }

  static void updateActiveParticles(){
    totalActiveParticles = 0;
    ClientState.totalParticles = particles.length;
    final totalParticles = ClientState.totalParticles;
    for (; totalActiveParticles < totalParticles; totalActiveParticles++){
      if (!particles[totalActiveParticles].active) break;
    }
  }

  static void sortParticles() {
    sortParticlesActive();
    updateActiveParticles();

    if (totalActiveParticles == 0) return;

    assert (verifyTotalActiveParticles());

    Engine.insertionSort(
      particles,
      compare: compareParticleRenderOrder,
      end: totalActiveParticles,
    );
  }
  
  static int compareParticleRenderOrder(Particle a, Particle b) {
    return a.sortOrder > b.sortOrder ? 1 : -1;
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
}