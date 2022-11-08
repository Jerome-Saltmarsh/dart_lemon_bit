import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_raining.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';
import 'package:lemon_math/library.dart';

import 'library.dart';

class GameState {
  static final sceneMetaDataSceneName = Watch<String?>(null);
  static final sceneEditable = Watch(false);
  static var srcXRainFalling = 6640.0;
  static var srcXRainLanding = 6739.0;
  static var nextLightning = 0;
  static final watchTimePassing = Watch(false);
  static final debugVisible = Watch(false);
  static final rain = Watch(Rain.None, onChanged: GameEvents.onChangedRain);
  // static var npcTextVisible = false;
  static final windAmbient = Watch(Wind.Calm, onChanged: GameEvents.onChangedWind);
  static final torchesIgnited = Watch(true);
  static const tileHeight = 24.0;
  static const colorPitchBlack = Color.fromRGBO(37, 32, 48, 1.0);
  static final raining = Watch(false, onChanged: onChangedRaining);
  static final hours = Watch(0, onChanged: GameEvents.onChangedHour);
  static final minutes = Watch(0);

  static final colorShades = [0.0, 0.4, 0.6, 0.7, 0.8, 0.95, 1.0]
      .map((opacity) => colorPitchBlack.withOpacity(opacity).value)
      .toList(growable: false);

  static final gameType = Watch<int?>(null, onChanged: onChangedGameType);
  static final edit = Watch(false, onChanged: GameEvents.onChangedEdit);
  static final player = Player();
  static var showAllItems = false;

  static final effects = <Effect>[];
  static final gameObjects = <GameObject>[];
  static final characters = <Character>[];
  static final npcs = <Character>[];
  static final zombies = <Character>[];
  static final particles = <Particle>[];
  static final projectiles = <Projectile>[];
  static final particleEmitters = <ParticleEmitter>[];
  static final floatingTexts = <FloatingText>[];

  static var totalGameObjects = 0;
  static var totalCharacters = 0;
  static var totalPlayers = 0;
  static var totalNpcs = 0;
  static var totalZombies = 0;
  static var totalParticles = 0;
  static var totalProjectiles = 0;

  static var totalActiveParticles = 0;
  static var ambientColor = colorShades[Shade.Bright];
  // static var nodesBake = Uint8List(nodesInitialSize);
  // static var nodesColor = Int32List(nodesInitialSize);
  // static var nodesOrientation = Uint8List(nodesInitialSize);
  // static var nodesShade = Uint8List(nodesInitialSize);
  // static var nodesTotal = nodesInitialSize;
  // static var nodesType = Uint8List(nodesInitialSize);
  // static var nodesVariation = List<bool>.generate(nodesInitialSize, (index) => false, growable: false);
  // static var nodesVisible = List<bool>.generate(nodesInitialSize, (index) => true, growable: false);
  // static var nodesVisibleIndex = Uint16List(nodesInitialSize);
  // static var nodesDynamicIndex = Uint16List(nodesInitialSize);
  // static var nodesWind = Uint8List(nodesInitialSize);
  static var visibleIndex = 0;
  static var dynamicIndex = 0;

  static var lightningFlashFrames = 0;

  static final triggerAlarmNoMessageReceivedFromServer = Watch(false);
  static final renderFrame = Watch(0);
  static final rendersSinceUpdate = Watch(0, onChanged: GameEvents.onChangedRendersSinceUpdate);

  static final gridShadows = Watch(true, onChanged: (bool value){
    refreshLighting();
  });


  static var nodesTotalZ = 0;
  static var nodesTotalRows = 0;
  static var nodesTotalColumns = 0;
  static var nodesLengthRow = 0.0;
  static var nodesLengthColumn = 0.0;
  static var nodesLengthZ = 0.0;
  static var nodesArea = 0;

  static final weatherBreeze = Watch(false);
  static var windLine = 0;
  static var move = true;

  static final lightning = Watch(Lightning.Off, onChanged: (Lightning value){
    if (value != Lightning.Off){
      nextLightning = 0;
    }
  });

  static final ambientShade = Watch(Shade.Bright, onChanged: GameEvents.onChangedAmbientShade);

  // static final inventoryOpen = Watch(false, onChanged: GameEvents.onChangedInventoryVisible);

  // WATCHES

  // QUERIES



  static int get bodyPartDuration => randomInt(120, 200);
  static bool get playMode => !editMode;
  static bool get editMode => edit.value;
  static bool get lightningOn => lightning.value != Lightning.Off;

  static Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }

  static Character? getPlayerCharacter(){
    for (var i = 0; i < totalCharacters; i++){
      if (characters[i].x != GamePlayer.position.x) continue;
      if (characters[i].y != GamePlayer.position.y) continue;
      return characters[i];
    }
    return null;
  }

  static int getNodeIndexV3(Vector3 v3) {
    return getNodeIndexZRC(v3.indexZ, v3.indexRow, v3.indexColumn);
  }

  static int getNodeIndexZRC(int z, int row, int column) {
    assert (GameQueries.isInboundZRC(z, row, column));
    return (z * nodesArea) + (row * nodesTotalColumns) + column;
  }

  static int convertNodeIndexToZ(int index) =>
      index ~/ nodesArea;

  static int convertNodeIndexToRow(int index) =>
      (index - ((index ~/ nodesArea) * nodesArea)) ~/ nodesTotalColumns;

  static int convertNodeIndexToColumn(int index) =>
      index - ((convertNodeIndexToZ(index) * nodesArea) + (convertNodeIndexToRow(index) * nodesTotalColumns));

  static int getV3RenderColor(Vector3 vector3) =>
      colorShades[getV3NodeBelowShade(vector3)];

  static int getV3RenderShade(Vector3 vector3) =>
      getV3NodeBelowShade(vector3);

  static int getV3NodeBelowShade(Vector3 vector3) =>
      getNodeShade(vector3.indexZ - 1, vector3.indexRow, vector3.indexColumn);

  static int getNodeShade(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? ambientShade.value
          : GameNodes.nodesShade[getNodeIndexZRC(z, row, column)];

  static bool outOfBoundsV3(Vector3 v3) =>
    outOfBoundsXYZ(v3.x, v3.y, v3.z);

  static bool outOfBounds(int z, int row, int column) =>
    z < 0 ||
    row < 0 ||
    column < 0 ||
    z >= nodesTotalZ ||
    row >= nodesTotalRows ||
    column >= nodesTotalColumns ;

  static bool outOfBoundsXYZ(double x, double y, double z) =>
     z < 0 ||
     y < 0 ||
     z < 0 ||
     z >= nodesLengthZ ||
     x >= nodesLengthRow ||
     y >= nodesLengthColumn ;

  // ACTIONS

  static void applyEmissions(){
    applyEmissionsCharacters();
    applyEmissionGameObjects();
    applyEmissionsParticles();
    applyEmissionsProjectiles();
    applyCharacterColors();
  }

  static void applyCharacterColors(){
    for (var i = 0; i < totalCharacters; i++){
      applyCharacterColor(characters[i]);
    }
  }

  static void applyCharacterColor(Character character){
    character.color = getV3RenderColor(character);
  }

  static void applyEmissionsParticles(){
    for (var i = 0; i < totalParticles; i++) {
      applyParticleEmission(particles[i]);
    }
  }

  static void applyEmissionsCharacters() {
    var maxBrightness = ambientShade.value - 1;
    if (maxBrightness < Shade.Bright) {
      maxBrightness = Shade.Bright;
    }
    if (maxBrightness > Shade.Medium) {
      maxBrightness = Shade.Medium;
    }
    for (var i = 0; i < totalCharacters; i++) {
      final character = characters[i];
      if (!character.allie) continue;
      applyVector3Emission(character, maxBrightness: maxBrightness);
    }
  }

  static void applyEmissionsProjectiles() {
    for (var i = 0; i < totalProjectiles; i++){
      applyProjectileEmission(projectiles[i]);
    }
  }

  static void applyProjectileEmission(Projectile projectile) {
    if (projectile.type == ProjectileType.Orb) {
      applyVector3Emission(projectile, maxBrightness: Shade.Very_Bright);
      return;
    }
    if (projectile.type == ProjectileType.Fireball) {
      applyVector3Emission(projectile, maxBrightness: Shade.Very_Bright);
      return;
    }
    if (projectile.type == ProjectileType.Arrow) {
      applyVector3Emission(projectile, maxBrightness: Shade.Medium);
      return;
    }
  }

  static void applyParticleEmission(Particle particle){
    if (!particle.active) return;
    if (particle.type == ParticleType.Orb_Shard){
      if (particle.duration > 12){
        return applyVector3Emission(particle, maxBrightness: Shade.Very_Bright);
      }
      if (particle.duration > 9){
        return applyVector3Emission(particle, maxBrightness: Shade.Bright);
      }
      if (particle.duration > 6){
        return applyVector3Emission(particle, maxBrightness: Shade.Medium);
      }
      if (particle.duration > 3) {
        return applyVector3Emission(particle, maxBrightness: Shade.Medium);
      }
      return applyVector3Emission(particle, maxBrightness: Shade.Dark);
    }

    if (particle.type == ParticleType.Light_Emission){
      if (particle.duration > 20){
        return applyVector3Emission(particle, maxBrightness: Shade.Very_Bright);
      }
      if (particle.duration > 10){
        return applyVector3Emission(particle, maxBrightness: Shade.Bright);
      }
      if (particle.duration > 7){
        return applyVector3Emission(particle, maxBrightness: Shade.Medium);
      }
      if (particle.duration > 5) {
        return applyVector3Emission(particle, maxBrightness: Shade.Dark);
      }
      if (particle.duration > 3) {
        return applyVector3Emission(particle, maxBrightness: Shade.Very_Dark);
      }
      return applyVector3Emission(particle, maxBrightness: Shade.Very_Very_Dark);
    }
  }

  static void applyVector3Emission(Vector3 v, {required int maxBrightness}){
    if (!GameQueries.inBoundsVector3(v)) return;
    applyEmissionDynamic(
      index: GameQueries.getNodeIndexV3(v),
      maxBrightness: maxBrightness,
    );
  }

  static void applyEmissionDynamic({
    required int index,
    required int maxBrightness,
  }){
    final zIndex = GameState.convertNodeIndexToZ(index);
    final rowIndex = GameState.convertNodeIndexToRow(index);
    final columnIndex = GameState.convertNodeIndexToColumn(index);
    final radius = Shade.Pitch_Black;
    final zMin = max(zIndex - radius, 0);
    final zMax = min(zIndex + radius, GameState.nodesTotalZ);
    final rowMin = max(rowIndex - radius, 0);
    final rowMax = min(rowIndex + radius, GameState.nodesTotalRows);
    final columnMin = max(columnIndex - radius, 0);
    final columnMax = min(columnIndex + radius, GameState.nodesTotalColumns);

    for (var z = zMin; z < zMax; z++){
      for (var row = rowMin; row < rowMax; row++){
        final a = (z * GameState.nodesArea) + (row * GameState.nodesTotalColumns);
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column < columnMax; column++) {
          final nodeIndex = a + column;
          var distance = b + (column - columnIndex).abs() - 1;
          final distanceValue = GameConvert.distanceToShade(distance, maxBrightness: maxBrightness);
          if (distanceValue >= GameNodes.nodesShade[nodeIndex]) continue;
          GameNodes.nodesShade[nodeIndex] = distanceValue;
          GameNodes.nodesDynamicIndex[GameState.dynamicIndex] = nodeIndex;
          GameState.dynamicIndex++;
        }
      }
    }
  }

  static void actionLightningFlash() {
    GameAudio.thunder(1.0);
    if (ambientShade.value == Shade.Very_Bright) return;
    ambientShade.value = Shade.Very_Bright;
    lightningFlashFrames = GameConfig.Lightning_Flash_Duration;
  }

  static void resetGridToAmbient(){
    final shade = ambientShade.value;
    for (var i = 0; i < GameNodes.nodesTotal; i++){
      GameNodes.nodesBake[i] = shade;
      GameNodes.nodesShade[i] = shade;
      dynamicIndex = 0;
    }
  }

  static void onChangedUpdateFrame(int value){
    rendersSinceUpdate.value = 0;
  }

  static void onChangedGameType(int? value){
    print("gamestream.onChangedGameType(${GameType.getName(value)})");
    if (value == null) {
      return;
    }
    edit.value = value == GameType.Editor;
    GameUI.timeVisible.value = GameType.isTimed(value);
    GameUI.mapVisible.value = value == GameType.Dark_Age;

    if (!Engine.isLocalHost){
      Engine.fullScreenEnter();
    }
  }

  static void actionGameDialogShowMap() {
    if (gameType.value != GameType.Dark_Age) return;

    if (player.gameDialog.value == GameDialog.Map){
      player.gameDialog.value = null;
      return;
    }
    player.gameDialog.value = GameDialog.Map;
  }

  static void clear() {
    GamePlayer.position.x = -1;
    GamePlayer.position.y = -1;
    totalZombies = 0;
    totalPlayers = 0;
    totalProjectiles = 0;
    totalNpcs = 0;
    particleEmitters.clear();
    particles.clear();
    player.gameDialog.value = null;
    player.npcTalkOptions.value = [];
    ServerState.interactMode.value = InteractMode.None;
    Engine.zoom = 1;
    Engine.redrawCanvas();
  }

  static void refreshDynamicLightGrid() {
    while (dynamicIndex >= 0) {
      final i = GameNodes.nodesDynamicIndex[dynamicIndex];
      GameNodes.nodesShade[i] = GameNodes.nodesBake[i];
      dynamicIndex--;
    }
    dynamicIndex = 0;
  }

  static void spawnParticle({
    required int type,
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed,
    bool checkCollision = true,
    double zv = 0,
    double weight = 1,
    int duration = 100,
    double scale = 1,
    double scaleV = 0,
    double rotation = 0,
    double rotationV = 0,
    bounciness = 0.5,
    double airFriction = 0.98,
    bool animation = false,
  }) {
    if (totalActiveParticles > GameConfig.Particles_Max) return;
    assert(duration > 0);
    final particle = getInstanceParticle();
    assert(!particle.active);
    particle.type = type;
    particle.x = x;
    particle.y = y;
    particle.z = z;
    particle.checkNodeCollision = checkCollision;
    particle.animation = animation;

    if (speed > 0){
      particle.xv = Engine.calculateAdjacent(angle, speed);
      particle.yv = Engine.calculateOpposite(angle, speed);
    } else {
      particle.xv = 0;
      particle.yv = 0;
    }

    particle.zv = zv;
    particle.weight = weight;
    particle.duration = duration;
    particle.scale = scale;
    particle.scaleV = scaleV;
    particle.rotation = rotation;
    particle.rotationVelocity = rotationV;
    particle.bounciness = bounciness;
    particle.airFriction = airFriction;
  }

  static void updateParticle(Particle particle) {
    if (!particle.active) return;
    if (particle.outOfBounds) return particle.deactivate();

    if (particle.animation) {
      if (particle.duration-- <= 0)
        particle.deactivate();
      return;
    }

    final nodeIndex = GameQueries.getNodeIndexV3(particle);
    final tile = GameNodes.nodesType[nodeIndex];
    final airBorn =
        !particle.checkNodeCollision || (
            tile == NodeType.Empty        ||
                tile == NodeType.Rain_Landing ||
                tile == NodeType.Rain_Falling ||
                tile == NodeType.Grass_Long   ||
                tile == NodeType.Fireplace)    ;


    if (particle.checkNodeCollision && !airBorn) {
      particle.deactivate();
      return;
    }

    if (!airBorn){
      particle.z = (particle.indexZ + 1) * tileHeight;
      particle.applyFloorFriction();
    } else {
      if (particle.type == ParticleType.Smoke){
        final wind = GameQueries.getWindAtV3(particle) * 0.01;
        particle.xv -= wind;
        particle.yv += wind;
      }
    }
    final bounce = particle.zv < 0 && !airBorn;
    particle.updateMotion();

    if (particle.outOfBounds) return particle.deactivate();

    if (bounce) {
      if (tile == NodeType.Water){
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

    if (!particle.active) {
      particle.deactivate();
    }
  }


  static void spawnParticleWaterDrop({
    required double x,
    required double y,
    required double z,
  }) {
    spawnParticle(
        type: ParticleType.Water_Drop,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0.5,
        zv: 1.5,
        weight: 5,
        duration: 15,
        rotation: 0,
        rotationV: 0,
        scaleV: 0,
        checkCollision: false
    );
  }

  static void spawnParticleArm({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    final type = ParticleType.Zombie_Arm;
    spawnParticle(
      type: type,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: randomBetween(0.04, 0.06),
      weight: 6,
      duration: bodyPartDuration,
      rotation: giveOrTake(pi),
      rotationV: giveOrTake(0.25),
      scale: 0.75,
      scaleV: 0,
    );
  }

  static void spawnParticleBlood({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    spawnParticle(
      type: ParticleType.Blood,
      x: x,
      y: y,
      z: z,
      zv: zv,
      angle: angle,
      speed: speed,
      weight: 5,
      duration: randomInt(220, 250),
      rotation: 0,
      rotationV: 0,
      scale: 0.6,
      scaleV: 0,
      bounciness: 0,
    );
  }

  static void spawnParticleOrgan({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    final type = ParticleType.Zombie_Torso;
    spawnParticle(
        type: type,
        x: x,
        y: y,
        z: z,
        angle: angle,
        speed: speed,
        zv: randomBetween(0.04, 0.06),
        weight: 6,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 1,
        scaleV: 0);
  }

  static void spawnParticleShell(
      double x,
      double y,
      double z,
      ) {
    spawnParticle(
      type: ParticleType.Shell,
      x: x,
      y: y,
      z: z,
      zv: 2,
      angle: randomAngle(),
      speed: 2,
      weight: 6,
      duration: randomInt(120, 200),
      rotation: randomInt(0, 7).toDouble(),
      rotationV: giveOrTake(0.25),
      scale: 0.6,
      scaleV: 0,
      bounciness: 0,
    );
  }

  static void spawnParticleShotSmoke({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    for (var i = 0; i < 4; i++) {
      spawnParticle(
          type: ParticleType.Smoke,
          x: x,
          y: y,
          z: 0.3,
          angle: angle,
          speed: speed,
          zv: 0.0075,
          weight: 0.0,
          duration: 120,
          rotation: 0,
          rotationV: 0,
          scale: 0.35 + giveOrTake(0.15),
          scaleV: 0.001 + giveOrTake(0.0005));
    }
  }

  static void spawnParticleRockShard(double x, double y){
    spawnParticle(
      type: ParticleType.Rock,
      x: x,
      y: y,
      z: randomBetween(0.0, 0.2),
      angle: randomAngle(),
      speed: randomBetween(0.5, 1.25),
      zv: randomBetween(0.1, 0.2),
      weight: 0.5,
      duration: randomInt(150, 200),
      scale: randomBetween(0.6, 1.25),
      scaleV: 0,
      rotation: randomAngle(),
      bounciness: 0.35,
    );
  }

  static void spawnParticleTreeShard(double x, double y, double z){
    spawnParticle(
      type: ParticleType.Tree_Shard,
      x: x,
      y: y,
      z: z,
      angle: randomAngle(),
      speed: randomBetween(0.5, 1.25),
      zv: randomBetween(0.1, 0.2),
      weight: 0.5,
      duration: randomInt(150, 200),
      scale: randomBetween(0.6, 1.25),
      scaleV: 0,
      rotation: randomAngle(),
      bounciness: 0.35,
    );
  }

  static void spawnParticleBlockWood(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Wood,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        checkCollision: false,
      );
    }
  }

  static void spawnParticleBlockGrass(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Grass,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        checkCollision: false,
      );
    }
  }

  static void spawnParticleBlockBrick(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Brick,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        checkCollision: false,
      );
    }
  }

  static void spawnParticleHeadZombie({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    spawnParticle(
      type: ParticleType.Zombie_Head,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: 0.06,
      weight: 6,
      duration: bodyPartDuration,
      rotation: 0,
      rotationV: 0.05,
      scale: 0.75,
      scaleV: 0,
    );
  }

  static void spawnParticleLegZombie({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    spawnParticle(
        type: ParticleType.Zombie_leg,
        x: x,
        y: y,
        z: z,
        angle: angle,
        speed: speed,
        zv: randomBetween(0, 0.03),
        weight: 6,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 0.75);
  }

  static void spawnEffect({
    required double x,
    required double y,
    required EffectType type,
    required int duration,
  }){
    final effect = getInstanceEffect();
    effect.x = x;
    effect.y = y;
    effect.type = type;
    effect.maxDuration = duration;
    effect.duration = 0;
    effect.enabled = true;
  }

  static void spawnParticleOrb(OrbType type, double x, double y) {
    spawnParticle(
      type: ParticleType.Orb_Ruby,
      x: x,
      y: y,
      z: 0.5,
      angle: 0,
      speed: 0,
      zv: 0.05,
      weight: 0.0,
      duration: 50,
      rotation: randomAngle(),
      rotationV: 0,
      scale: 0.3,
    );
  }

  static void freezeCircle({
    required double x,
    required double y
  }){
    spawnEffect(x: x, y: y, type: EffectType.FreezeCircle, duration: 45);
  }

  static void spawnParticleOrbShard({
    required double x,
    required double y,
    required double z,
    required double angle,
    int duration = 12,
    double speed = 1.0,
    double scale = 0.75
  }) {
    spawnParticle(
      type: ParticleType.Orb_Shard,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: angle,
      speed: speed,
      scaleV: 0,
      weight: 0,
      duration: duration,
      scale: scale,
    );
  }

  static void spawnParticleBubbles({
    required int count,
    required double x,
    required double y,
    required double z,
    required double angle,
  }){
    spawnParticleBubble(
      x: x,
      y: y,
      z: z,
      angle: angle + giveOrTake(piQuarter),
      speed: 3 + giveOrTake(2),
    );
  }



  static void spawnParticleBubble({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
    double speed = 0,
  }) {
    spawnParticle(
      type: randomBool() ? ParticleType.Bubble : ParticleType.Bubble_Small,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: 0,
      speed: speed,
      scaleV: 0,
      weight: -0.5,
      duration: duration,
      scale: scale,
    );
  }


  static void spawnParticleBulletRing({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
    double speed = 0,
  }) {
    spawnParticle(
      type: ParticleType.Bullet_Ring,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: 0,
      speed: speed,
      scaleV: 0,
      weight: -0.5,
      duration: duration,
      scale: scale,
    );
  }

  static void spawnParticleStrikeBlade({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Blade,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: angle,
      speed: speed,
      scaleV: 0,
      weight: 0,
      duration: duration,
      scale: scale,
      checkCollision: false,
      animation: true,
    );
  }

  static void spawnParticleAnimation({
    required double x,
    required double y,
    required double z,
    required int type,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
  }) =>
      spawnParticle(
        type: type,
        x: x,
        y: y,
        z: z,
        angle: angle,
        rotation: angle,
        speed: 0,
        scaleV: 0,
        weight: 0,
        duration: duration,
        scale: scale,
        checkCollision: false,
        animation: true,
      );

  static void spawnParticleStarExploding({
    required double x,
    required double y,
    required double z,
  }) {
    spawnParticle(
        type: ParticleType.Star_Explosion,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0,
        weight: 0,
        duration: 100,
        scale: 0.75
    );
  }

  static void spawnParticleLightEmission({
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
      );


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

  static GameObject getInstanceGameObject(){
    if (gameObjects.length <= totalGameObjects){
      gameObjects.add(GameObject());
    }
    return gameObjects[totalGameObjects++];
  }

  static FloatingText getInstanceFloatingText(){
    for (final floatingText in floatingTexts) {
      if (floatingText.duration > 0) continue;
      return floatingText;
    }
    final instance = FloatingText();
    GameState.floatingTexts.add(instance);
    return instance;
  }

  static Effect getInstanceEffect(){
    for (final effect in effects){
      if (effect.enabled) continue;
      return effect;
    }
    final effect = Effect();
    effects.add(effect);
    return effect;
  }


  static void spawnParticleFire({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0
  }) {
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
    );
  }

  static void spawnParticleFirePurple({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double speed = 0.0,
    double angle = 0.0,
  }) {
    spawnParticle(
      type: ParticleType.Fire_Purple,
      x: x,
      y: y,
      z: z,
      zv: 1,
      angle: angle,
      rotation: 0,
      speed: speed,
      scaleV: 0.01,
      weight: -1,
      duration: duration,
      scale: scale,
    );
  }


  static void spawnParticleSlimeDeath({
    required double x,
    required double y,
    required double z,
  }) {
    spawnParticle(
      type: ParticleType.Character_Death_Slime,
      x: x,
      y: y,
      z: z,
      zv: 0,
      angle: 0,
      rotation: 0,
      speed: 0,
      scaleV: 0.01,
      weight: -1,
      duration: 0,
      scale: 1.0,
    );
  }

  /// do this during the draw call so that particles are smoother
  static void updateParticles() {
    for (final particle in particles) {
      if (!particle.active) continue;
      updateParticle(particle);
      particle.frame++;
    }
  }


  static void interpolatePlayer(){

    if (!player.interpolating.value) return;

    if (rendersSinceUpdate.value == 0) {
      return;
    }
    if (rendersSinceUpdate.value != 1) return;

    final playerCharacter = getPlayerCharacter();
    if (playerCharacter == null) return;
    final velocityX = GamePlayer.position.x - GamePlayer.previousPosition.x;
    final velocityY = GamePlayer.position.y - GamePlayer.previousPosition.y;
    final velocityZ = GamePlayer.position.z - GamePlayer.previousPosition.z;
    playerCharacter.x += velocityX;
    playerCharacter.y += velocityY;
    playerCharacter.z -= velocityZ;
  }

  static void renderEditMode() {
    if (playMode) return;
    if (GameEditor.gameObjectSelected.value){
      Engine.renderCircleOutline(
        sides: 24,
        radius: GameEditor.gameObjectSelectedRadius.value,
        x: GameEditor.gameObject.renderX,
        y: GameEditor.gameObject.renderY,
        color: Colors.white,
      );
      return renderCircleV3(GameEditor.gameObject);
    }

    renderEditWireFrames();
    GameRender.renderMouseWireFrame();

    // final nodeData = EditState.selectedNodeData.value;
    // if (nodeData != null){
    //   Engine.renderCircleOutline(
    //        radius: nodeData.spawnRadius.toDouble(),
    //        x: EditState.renderX,
    //        y: EditState.renderY,
    //        color: Colors.white,
    //        sides: 8,
    //    );
    // }
  }

  static void renderEditWireFrames() {
    for (var z = 0; z < GameEditor.z; z++) {
      GameRender.renderWireFrameBlue(z, GameEditor.row, GameEditor.column);
    }
    GameRender.renderWireFrameRed(GameEditor.row, GameEditor.column, GameEditor.z);
  }

  static void update() {
    // updateGameActions();

    GameAnimation.updateAnimationFrame();
    updateParticleEmitters();
    updateProjectiles();
    GameAudio.update();
    updateLightning();

    if (player.messageTimer > 0) {
      player.messageTimer--;
      if (player.messageTimer == 0){
        player.message.value = "";
      }
    }

    if (lightningFlashFrames > 0) {
      lightningFlashFrames--;
       if (lightningFlashFrames <= 0){
         GameActions.setAmbientShadeToHour();
       }
    }

    GameIO.readPlayerInput();
    GameNetwork.sendClientRequestUpdate();
  }

  static void updateLightning(){
    if (lightning.value != Lightning.On) return;
    if (nextLightning-- > 0) return;
    GameState.actionLightningFlash();
    nextLightning = randomInt(200, 1500);
  }

  static void applyEmissionGameObjects() {
    // for (var i = 0; i < totalGameObjects; i++){
    //   if (!GameObjectType.emitsLightBright(gameObjects[i].type)) continue;
    //   applyVector3Emission(gameObjects[i], maxBrightness: Shade.Very_Bright);
    // }
    for (var i = 0; i < totalGameObjects; i++){
      final gameObject = gameObjects[i];
      if (gameObject.type != ItemType.GameObjects_Candle) continue;
      final nodeIndex = GameQueries.getNodeIndexV3(gameObject);
      final nodeShade = GameNodes.nodesShade[nodeIndex];
      setNodeShade(nodeIndex, nodeShade - 1);
      if (gameObject.indexZ > 0){
        final nodeBelowIndex = GameQueries.getNodeIndexBelowV3(gameObject);
        final nodeBelowShade = GameNodes.nodesShade[nodeBelowIndex];
        setNodeShade(nodeBelowIndex, nodeBelowShade - 1);
      }
    }
  }

  static void setNodeShade(int index, int shade) {
    if (shade < 0) {
      GameNodes.nodesShade[index] = 0;
      return;
    }
    if (shade > Shade.Pitch_Black){
      GameNodes.nodesShade[index] = Shade.Pitch_Black;
      return;
    }
    GameNodes.nodesShade[index] = shade;
  }

  static void toggleShadows () => gridShadows.value = !gridShadows.value;

  static void actionGameDialogShowQuests() {
    if (gameType.value != GameType.Dark_Age) return;

    if (player.gameDialog.value == GameDialog.Quests){
      player.gameDialog.value = null;
      return;
    }
    player.gameDialog.value = GameDialog.Quests;
  }

  // static void actionToggleInventoryVisible() =>
  //   GamePlayer.interactMode.value == InteractMode.None
  //       ? actionInventoryShow()
  //       : actionInventoryClose();
  //
  //   static void actionInventoryClose() =>
  //     GamePlayer.interactMode.value = InteractMode.None;
  //
  //   static void actionInventoryShow() =>
  //     GamePlayer.interactMode.value = InteractMode.Inventory;

    static void updateParticleEmitters(){
      for (final emitter in particleEmitters) {
        if (emitter.next-- > 0) continue;
        emitter.next = emitter.rate;
        final particle = getInstanceParticle();
        particle.x = emitter.x;
        particle.y = emitter.y;
        particle.z = emitter.z;
        emitter.emit(particle);
      }
    }

    static void updateProjectiles() {
      for (var i = 0; i < GameState.totalProjectiles; i++) {
        final projectile = GameState.projectiles[i];
        if (projectile.type == ProjectileType.Fireball) {
          GameState.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
          GameState.spawnParticleBubble(
            x: projectile.x + giveOrTake(5),
            y: projectile.y + giveOrTake(5),
            z: projectile.z,
            angle: (projectile.angle + pi) + giveOrTake(piHalf ),
            speed: 1.5,
          );
          continue;
        }

        if (projectile.type == ProjectileType.Bullet) {
          // GameState.spawnParticleBubble(
          //   x: projectile.x + giveOrTake(5),
          //   y: projectile.y + giveOrTake(5),
          //   z: projectile.z,
          //   angle: (projectile.angle + pi) + giveOrTake(piHalf ),
          //   speed: 1.5,
          // );
          // GameState.spawnParticleBulletRing(
          //   x: projectile.x,
          //   y: projectile.y,
          //   z: projectile.z,
          //   angle: projectile.angle,
          //   speed: 1.5,
          // );
          continue;
        }

        if (projectile.type == ProjectileType.Orb) {
          GameState.spawnParticleOrbShard(x: projectile.x, y: projectile.y, z: projectile.z, angle: randomAngle());
        }
      }
    }


    static void refreshLighting(){
      GameState.resetGridToAmbient();
      if (GameState.gridShadows.value){
        applyShadows();
      }
      applyBakeMapEmissions();
    }

    static void applyShadows(){
      if (GameState.ambientShade.value > Shade.Very_Bright) return;
      applyShadowsMidAfternoon();
    }

    static void applyShadowsMidAfternoon() {
      applyShadowAt(directionZ: -1, directionRow: 0, directionColumn: 0, maxDistance: 1);
    }

    static void applyShadowAt({
      required int directionZ,
      required int directionRow,
      required int directionColumn,
      required int maxDistance,
    }){
      final current = GameState.ambientShade.value;
      final shadowShade = current >= Shade.Pitch_Black ? current : current + 1;

      for (var z = 0; z < GameState.nodesTotalZ; z++) {
        for (var row = 0; row < GameState.nodesTotalRows; row++){
          for (var column = 0; column < GameState.nodesTotalColumns; column++){
            // final tile = grid[z][row][column];
            final index = GameState.getNodeIndexZRC(z, row, column);
            final tile = GameNodes.nodesType[index];
            if (!castesShadow(tile)) continue;
            var projectionZ = z + directionZ;
            var projectionRow = row + directionRow;
            var projectionColumn = column + directionColumn;
            while (
            projectionZ >= 0 &&
                projectionRow >= 0 &&
                projectionColumn >= 0 &&
                projectionZ < GameState.nodesTotalZ &&
                projectionRow < GameState.nodesTotalRows &&
                projectionColumn < GameState.nodesTotalColumns
            ) {
              final shade = GameNodes.nodesBake[index];
              if (shade < shadowShade){
                if (GameQueries.gridNodeZRCType(projectionZ + 1, projectionRow, projectionColumn) == NodeType.Empty){
                  GameNodes.nodesBake[index] = shadowShade;
                }
              }
              projectionZ += directionZ;
              projectionRow += directionRow;
              projectionColumn += directionColumn;
            }
          }
        }
      }
    }

    static bool castesShadow(int type) =>
    type == NodeType.Brick_2 ||
        type == NodeType.Water ||
        type == NodeType.Brick_Top;

    static bool gridIsUnderSomething(int z, int row, int column){
      if (GameState.outOfBounds(z, row, column)) return false;
      for (var zIndex = z + 1; zIndex < GameState.nodesTotalZ; zIndex++){
        if (!GameQueries.gridNodeZRCTypeRainOrEmpty(z, row, column)) return false;
      }
      return true;
    }

    static bool gridIsPerceptible(int index){
      if (index < 0) return true;
      if (index >= GameNodes.nodesTotal) return true;
      while (true){
        index += GameState.nodesArea;
        index++;
        index += GameState.nodesTotalColumns;
        if (index >= GameNodes.nodesTotal) return true;
        if (GameNodes.nodesOrientation[index] != NodeOrientation.None){
          return false;
        }
      }
    }

    static void refreshGridMetrics(){
      GameState.nodesLengthRow = GameState.nodesTotalRows * tileSize;
      GameState.nodesLengthColumn = GameState.nodesTotalColumns * tileSize;
      GameState.nodesLengthZ = GameState.nodesTotalZ * tileHeight;
    }

    static void applyBakeMapEmissions() {
      for (var zIndex = 0; zIndex < GameState.nodesTotalZ; zIndex++) {
        for (var rowIndex = 0; rowIndex < GameState.nodesTotalRows; rowIndex++) {
          for (var columnIndex = 0; columnIndex < GameState.nodesTotalColumns; columnIndex++) {
            if (!NodeType.emitsLight(
                GameQueries.gridNodeZRCType(zIndex, rowIndex, columnIndex))
            ) continue;
            applyEmissionBake(
              zIndex: zIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              maxBrightness: Shade.Very_Bright,
              radius: 7,
            );
          }
        }
      }

      for (final gameObject in GameState.gameObjects){
        if (gameObject.type == ItemType.GameObjects_Crystal){
          applyEmissionBake(
            zIndex: gameObject.indexZ,
            rowIndex: gameObject.indexRow,
            columnIndex: gameObject.indexColumn,
            maxBrightness: Shade.Very_Bright,
            radius: 7,
          );
        }
      }
    }

    static void applyEmissionBake({
      required int zIndex,
      required int rowIndex,
      required int columnIndex,
      required int maxBrightness,
      int radius = 5,
    }){
      final zMin = max(zIndex - radius, 0);
      final zMax = min(zIndex + radius, GameState.nodesTotalZ);
      final rowMin = max(rowIndex - radius, 0);
      final rowMax = min(rowIndex + radius, GameState.nodesTotalRows);
      final columnMin = max(columnIndex - radius, 0);
      final columnMax = min(columnIndex + radius, GameState.nodesTotalColumns);

      for (var z = zMin; z < zMax; z++){
        for (var row = rowMin; row < rowMax; row++){
          for (var column = columnMin; column < columnMax; column++) {
            final nodeIndex = GameState.getNodeIndexZRC(z, row, column);
            var distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
            final distanceValue = GameConvert.distanceToShade(distance, maxBrightness: maxBrightness);
            if (distanceValue >= GameNodes.nodesBake[nodeIndex]) continue;
            GameNodes.nodesBake[nodeIndex] = distanceValue;
            GameNodes.nodesShade[nodeIndex] = distanceValue;
          }
        }
      }
    }

    static void gridWindResetToAmbient(){
      final ambientWindIndex = windAmbient.value.index;
      for (var i = 0; i < GameNodes.nodesTotal; i++){
        GameNodes.nodesWind[i] = ambientWindIndex;
      }
    }

    static void spawnFloatingText(double x, double y, String text) {
      final floatingText = getInstanceFloatingText();
      floatingText.duration = 50;
      floatingText.x = x;
      floatingText.y = y;
      floatingText.xv = giveOrTake(0.2);
      floatingText.value = text;
    }

    static void setNodeType(int z, int row, int column, int type){
      if (z < 0)
        return;
      if (row < 0)
        return;
      if (column < 0)
        return;
      if (z >= nodesTotalZ)
        return;
      if (row >= nodesTotalRows)
        return;
      if (column >= nodesTotalColumns)
        return;

      GameNodes.nodesType[getNodeIndexZRC(z, row, column)] = type;
    }
}