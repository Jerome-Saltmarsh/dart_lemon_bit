import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/particle_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game_network.dart';
import 'package:gamestream_flutter/game_render.dart';
import 'package:gamestream_flutter/game_ui.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/convert/convert_distance_to_shade.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/effects.dart';
import 'package:gamestream_flutter/isometric/enums/camera_mode.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/events/on_action_finished_lightning_flash.dart';
import 'package:gamestream_flutter/isometric/events/on_camera_mode_changed.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_ambient_shade.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_edit.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/update.dart';
import 'package:gamestream_flutter/isometric_web/read_player_input.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'isometric/events/on_inventory_visible_changed.dart';

class GameState {


  static const tileHeight = 24.0;
  static const colorPitchBlack = Color.fromRGBO(37, 32, 48, 1.0);

  static final hours = Watch(0);
  static final minutes = Watch(0);

  static final colorShades = [0.0, 0.4, 0.6, 0.7, 0.8, 0.95, 1.0]
      .map((opacity) => colorPitchBlack.withOpacity(opacity).value)
      .toList(growable: false);

  static final gameType = Watch<int?>(null, onChanged: onChangedGameType);
  static final edit = Watch(false, onChanged: onChangedEdit);
  static final player = Player();

  static final gameObjects = <GameObject>[];
  static final characters = <Character>[];
  static final players = <Character>[];
  static final npcs = <Character>[];
  static final zombies = <Character>[];
  static final particles = <Particle>[];
  static final projectiles = <Projectile>[];
  static final particleEmitters = <ParticleEmitter>[];

  static var totalGameObjects = 0;
  static var totalCharacters = 0;
  static var totalPlayers = 0;
  static var totalNpcs = 0;
  static var totalZombies = 0;
  static var totalParticles = 0;
  static var totalProjectiles = 0;

  static var totalActiveParticles = 0;
  static var ambientColor = colorShades[Shade.Bright];
  static var nodesBake = Uint8List(nodesInitialSize);
  static var nodesColor = Int32List(nodesInitialSize);
  static var nodesOrientation = Uint8List(nodesInitialSize);
  static var nodesShade = Uint8List(nodesInitialSize);
  static var nodesTotal = nodesInitialSize;
  static var nodesType = Uint8List(nodesInitialSize);
  static var nodesVariation = List<bool>.generate(nodesInitialSize, (index) => false, growable: false);
  static var nodesVisible = List<bool>.generate(nodesInitialSize, (index) => true, growable: false);
  static var nodesVisibleIndex = Uint16List(nodesInitialSize);
  static var nodesDynamicIndex = Uint16List(nodesInitialSize);
  static var nodesWind = Uint8List(nodesInitialSize);
  static var visibleIndex = 0;
  static var dynamicIndex = 0;

  static final triggerAlarmNoMessageReceivedFromServer = Watch(false);
  static final renderFrame = Watch(0);
  static final rendersSinceUpdate = Watch(0, onChanged: onChangedRendersSinceUpdate);

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

  static final ambientShade = Watch(Shade.Bright, onChanged: onChangedAmbientShade);
  static const nodesInitialSize = 70 * 70 * 8;

  static const cameraModes = CameraMode.values;
  static final cameraModeWatch = Watch(CameraMode.Chase, onChanged: onCameraModeChanged);
  static CameraMode get cameraMode => cameraModeWatch.value;

  static final inventoryVisible = Watch(false, onChanged: onInventoryVisibleChanged);
  // QUERIES

  static bool get playMode => !editMode;
  static bool get editMode => edit.value;

  static Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }

  static Character? getPlayerCharacter(){
    for (var i = 0; i < totalCharacters; i++){
      if (characters[i].x != player.x) continue;
      if (characters[i].y != player.y) continue;
      return characters[i];
    }
    return null;
  }

  static int getNodeIndexV3(Vector3 v3) {
    return getNodeIndexZRC(v3.indexZ, v3.indexRow, v3.indexColumn);
  }

  static int getNodeIndexZRC(int z, int row, int column) {
    assert (verifyInBoundZRC(z, row, column));
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
          : nodesShade[getNodeIndexZRC(z, row, column)];

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
    if (!inBoundsVector3(v)) return;
    applyEmissionDynamic(
      index: gridNodeIndexVector3(v),
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
          final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
          if (distanceValue >= GameState.nodesShade[nodeIndex]) continue;
          GameState.nodesShade[nodeIndex] = distanceValue;
          GameState.nodesDynamicIndex[GameState.dynamicIndex] = nodeIndex;
          GameState.dynamicIndex++;
        }
      }
    }
  }


  static void actionLightningFlash() {
    GameAudio.thunder(1.0);
    if (ambientShade.value == Shade.Very_Bright) return;
    ambientShade.value = Shade.Very_Bright;
    runAction(duration: 8, action: onActionFinishedLightningFlash);
  }

  static void resetGridToAmbient(){
    final shade = ambientShade.value;
    for (var i = 0; i < nodesTotal; i++){
      nodesBake[i] = shade;
      nodesShade[i] = shade;
      dynamicIndex = 0;
    }
  }

  static void rainOff() {
    for (var i = 0; i < nodesTotal; i++) {
      if (!NodeType.isRain(nodesType[i])) continue;
      nodesType[i] = NodeType.Empty;
      nodesOrientation[i] = NodeOrientation.None;
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
    player.x = -1;
    player.y = -1;
    totalZombies = 0;
    totalPlayers = 0;
    totalProjectiles = 0;
    totalNpcs = 0;
    particleEmitters.clear();
    particles.clear();
    player.gameDialog.value = null;
    player.npcTalkOptions.value = [];
    player.npcTalk.value = null;
    Engine.zoom = 1;
    Engine.redrawCanvas();
  }

  static void refreshDynamicLightGrid() {
    while (dynamicIndex >= 0) {
      final i = nodesDynamicIndex[dynamicIndex];
      nodesShade[i] = nodesBake[i];
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
    assert(duration > 0);
    final particle = getParticleInstance();
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

    final nodeIndex = gridNodeIndexVector3(particle);
    final tile = nodesType[nodeIndex];
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
        final wind = gridNodeWindGetVector3(particle) * 0.01;
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
    final effect = getEffect();
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

  static void spawnParticleBubbleV3(Vector3 value, {
    int duration = 100,
    double scale = 1.0
  }) =>
      spawnParticleBubble(
        x: value.x,
        y: value.y,
        z: value.z,
        duration: duration,
        scale: scale,
      );

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
  static Particle getParticleInstance() {
    totalActiveParticles++;
    if (totalActiveParticles >= totalParticles){
      final instance = Particle();
      particles.add(instance);
      return instance;
    }
    return particles[totalActiveParticles];
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

  static void renderCanvas(Canvas canvas, Size size) {
    /// particles are only on the ui and thus can update every frame
    /// this makes them much smoother as they don't freeze
    updateParticles();
    renderFrame.value++;
    interpolatePlayer();
    updateCameraMode();
    GameRender.renderSprites();
    renderEditMode();
    GameRender.renderMouseTargetName();
    rendersSinceUpdate.value++;
  }

  /// do this during the draw call so that particles are smoother
  static void updateParticles() {
    for (final particle in particles) {
      updateParticle(particle);
    }
    updateParticleFrames();
  }

  static void interpolatePlayer(){

    if (!player.interpolating.value) return;

    if (rendersSinceUpdate.value == 0) {
      return;
    }
    if (rendersSinceUpdate.value != 1) return;

    final playerCharacter = getPlayerCharacter();
    if (playerCharacter == null) return;
    final velocityX = player.x - player.previousPosition.x;
    final velocityY = player.y - player.previousPosition.y;
    final velocityZ = player.z - player.previousPosition.z;
    playerCharacter.x += velocityX;
    playerCharacter.y += velocityY;
    playerCharacter.z -= velocityZ;
  }

  static void updateCameraMode() {
    switch (cameraMode){
      case CameraMode.Chase:
        Engine.cameraFollow(player.renderX, player.renderY, 0.00075);
        break;
      case CameraMode.Locked:
        Engine.cameraFollow(player.renderX, player.renderY, 1.0);
        break;
      case CameraMode.Free:
        break;
    }
  }

  static void renderEditMode() {
    if (playMode) return;
    if (EditState.gameObjectSelected.value){
      Engine.renderCircleOutline(
        sides: 24,
        radius: EditState.gameObjectSelectedRadius.value,
        x: EditState.gameObject.renderX,
        y: EditState.gameObject.renderY,
        color: Colors.white,
      );
      return renderCircleV3(EditState.gameObject);
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
    for (var z = 0; z < EditState.z; z++) {
      GameRender.renderWireFrameBlue(z, EditState.row, EditState.column);
    }
    GameRender.renderWireFrameRed(EditState.row, EditState.column, EditState.z);
  }

  static void update() {
    updateIsometric();
    readPlayerInput();
    GameNetwork.sendClientRequestUpdate();
  }

  static void applyEmissionGameObjects() {
    for (var i = 0; i < totalGameObjects; i++){
      if (!GameObjectType.emitsLightBright(gameObjects[i].type)) continue;
      applyVector3Emission(gameObjects[i], maxBrightness: Shade.Very_Bright);
    }
    for (var i = 0; i < totalGameObjects; i++){
      final gameObject = gameObjects[i];
      if (gameObject.type != GameObjectType.Candle) continue;
      final nodeIndex = gridNodeIndexVector3(gameObject);
      final nodeShade = nodesShade[nodeIndex];
      setNodeShade(nodeIndex, nodeShade - 1);
      if (gameObject.indexZ > 0){
        final nodeBelowIndex = gridNodeIndexVector3NodeBelow(gameObject);
        final nodeBelowShade = nodesShade[nodeBelowIndex];
        setNodeShade(nodeBelowIndex, nodeBelowShade - 1);
      }
    }
  }

  static void setNodeShade(int index, int shade) {
    if (shade < 0) {
      nodesShade[index] = 0;
      return;
    }
    if (shade > Shade.Pitch_Black){
      nodesShade[index] = Shade.Pitch_Black;
      return;
    }
    nodesShade[index] = shade;
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

  static void actionToggleInventoryVisible() => inventoryVisible.value = !inventoryVisible.value;

  static void actionInventoryClose(){
    inventoryVisible.value = false;
  }

  static void actionShowInventory(){
    inventoryVisible.value = true;
  }

}