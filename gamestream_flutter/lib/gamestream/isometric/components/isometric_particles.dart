
import 'dart:math';
import 'dart:typed_data';

import 'package:gamestream_flutter/gamestream/isometric/classes/particle_flying.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_glow.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_whisp.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/node_visibility.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/lemon_components.dart';
import 'package:lemon_math/src.dart';

import '../../../isometric/classes/particle.dart';
import 'isometric_component.dart';

class IsometricParticles with IsometricComponent implements Updatable {

  var updateWindNodesEnabled = true;

  /// a wind node
  /// [0] enabled
  /// [1, 2, 3, 4, 5] velocityX
  /// [6, 7, 8, 9, 10] velocityY
  /// [11, 12, 13, 14, 15] velocityZ
  /// [16, 17, 18, 19, 20] accelerationX
  /// [21, 22, 23, 24, 25] accelerationY
  /// [26, 27, 28, 29, 30] accelerationZ
  var windIndexes = Uint16List(0);

  var windUpdateZ = 0;

  void updateWindNodes(){
    if (this.windIndexes.length != scene.nodeTypes.length){
      this.windIndexes = Uint16List(scene.nodeTypes.length);
    }
    if (!updateWindNodesEnabled){
      return;
    }

    final windIndexes = this.windIndexes;
    final windIndexesLength = windIndexes.length;

    if (windIndexesLength == 0) {
      return;
    }

    final area = scene.area;
    final totalColumns = scene.totalColumns;
    final totalRows = scene.totalRows;
    final totalZ = scene.totalZ;

    final totalRowsMinusOne = totalRows - 1;
    final totalColumnsMinusOne = totalColumns - 1;
    final totalZMinusOne = totalZ - 1;

    this.windUpdateZ = (this.windUpdateZ + 1) % totalZ;
    final windUpdateZ = this.windUpdateZ;

    for (var row = 0; row < totalRows; row++){
      final startRow = windUpdateZ + (row * totalColumns);
      for (var column = 0; column < totalColumns; column++){
        final startColumn = startRow + column;
        final windIndex = startColumn;
        var wind = windIndexes[windIndex];
        final windPrevious = wind;
        final windEnabled = Wind.getEnabled(wind);

        if (!windEnabled){
          continue;
        }

        var windVelocityX = Wind.getVelocityX(wind);
        var windVelocityY = Wind.getVelocityY(wind);
        var windVelocityZ = Wind.getVelocityZ(wind);

        if (windVelocityX != 0) {
          final windVelocityXPositive = windVelocityX > 0;
          final friction = windVelocityXPositive ? -1 : 1;
          final indexDiff = windVelocityXPositive ? totalColumns : -totalColumns;
          final nextIndex = windIndex + indexDiff;
          wind = Wind.setVelocityX(wind, windVelocityX + friction);

          if (
            (!windVelocityXPositive && row > 0) ||
            (windVelocityXPositive && row < totalRowsMinusOne)
          ) {
            final nextWind = windIndexes[nextIndex];
            if (Wind.getEnabled(nextWind)){
              final nextWindAccelerationX = Wind.getAccelerationX(nextWind);
              windIndexes[nextIndex] = Wind.setAccelerationX(
                nextWind,
                nextWindAccelerationX + windVelocityX + friction,
              );
            }
          }
        }

        if (windVelocityY != 0) {
          final windVelocityYPositive = windVelocityY > 0;
          final friction = windVelocityYPositive ? -1 : 1;
          final indexDiff = windVelocityYPositive ? 1 : -1;
          final nextIndex = windIndex + indexDiff;
          wind = Wind.setVelocityY(wind, windVelocityY + friction);

          if (
            (!windVelocityYPositive && column > 0) ||
            (windVelocityYPositive && column < totalColumnsMinusOne)
          ) {
            final nextWind = windIndexes[nextIndex];
            if (Wind.getEnabled(nextWind)){
              final nextWindAccelerationY = Wind.getAccelerationY(nextWind);
              windIndexes[nextIndex] = Wind.setAccelerationY(
                nextWind,
                nextWindAccelerationY + windVelocityY + friction,
              );
            }
          }
        }

        if (windVelocityZ != 0) {
          final windVelocityZPositive = windVelocityZ > 0;
          final friction = windVelocityZPositive ? -1 : 1;
          final indexDiff = windVelocityZPositive ? area : -area;
          final nextIndex = windIndex + indexDiff;
          wind = Wind.setVelocityZ(wind, windVelocityZ + friction);

          if (
            (!windVelocityZPositive && windUpdateZ > 0) ||
            (windVelocityZPositive && windUpdateZ < totalZMinusOne)
          ) {
            final nextWind = windIndexes[nextIndex];
            if (Wind.getEnabled(nextWind)){
              final nextWindAccelerationZ = Wind.getAccelerationZ(nextWind);
              windIndexes[nextIndex] = Wind.setAccelerationZ(
                nextWind,
                nextWindAccelerationZ + windVelocityZ + friction,
              );
            }
          }
        }

        final windAccelerationX = Wind.getAccelerationX(wind);
        if (windAccelerationX != 0) {
          wind = Wind.setVelocityX(wind, Wind.getVelocityX(wind) + windAccelerationX);
          wind = Wind.setAccelerationX(wind, 0);
        }

        final windAccelerationY = Wind.getAccelerationY(wind);
        if (windAccelerationY != 0) {
          wind = Wind.setVelocityY(wind, Wind.getVelocityY(wind) + windAccelerationY);
          wind = Wind.setAccelerationY(wind, 0);
        }

        final windAccelerationZ = Wind.getAccelerationZ(wind);
        if (windAccelerationZ != 0) {
          wind = Wind.setVelocityZ(wind, Wind.getVelocityZ(wind) + windAccelerationZ);
          wind = Wind.setAccelerationZ(wind, 0);
        }

        if (windPrevious != wind){
          windIndexes[windIndex] = wind;
        }
      }
    }
  }

  static const windStrengthMultiplier = 0.003;

  var maxVelocity = 1.25;
  var windy = false;
  var windStrength = 0.0;
  var nextParticleFrame = 0;
  var nodeType = 0;

  late final whispColors = [
    colors.aqua_1.value,
    colors.purple_0.value,
    colors.pink_0.value,
    colors.teal_0.value,
    colors.white.value,
    colors.blue_0.value,
    colors.grey_0.value,
    colors.apricot_0.value,
  ];

  final activated = <Particle>[];
  final deactivated = <Particle>[];

  final mystIndexes = <int>[];
  final indexesWaterDrops = <int>[];

  var nextMystEmission = 0;
  var nextEmissionWaterDrop = 0;

  Particle getInstance() {
    final deactivated = this.deactivated;

    if (deactivated.isNotEmpty){
       final particle = deactivated.first;
       activateParticle(particle);
       return particle;
    }

    final instance = Particle();
    instance.deactivating = false;
    activated.add(instance);
    return instance;
  }

  void clearParticles(){
    print('particles.clearParticles()');
    activated.clear();
  }

  Particle spawnParticle({
    required int particleType,
    required double x,
    required double y,
    required double z,
    double speed = 0,
    double angle = 0,
    double zv = 0,
    double weight = 1,
    int duration = 100,
    double scale = 1,
    double scaleV = 0,
    double rotation = 0,
    double rotationV = 0,
    bounciness = 0.5,
    int delay = 0,
  }) {
    assert (duration > 0);

    final particle = getInstance();
    particle.type = particleType;
    particle.frictionAir = ParticleType.frictionAir[particleType] ?? 1.0;
    particle.blownByWind = ParticleType.blownByWind.contains(particleType);
    particle.deactiveOnNodeCollision = ParticleType.deactivateOnNodeCollision.contains(particleType);
    particle.x = x;
    particle.y = y;
    particle.z = z;

    if (particle.deactiveOnNodeCollision){
      particle.nodeCollidable = true;
    }

    particle.animation = const [
      ParticleType.Lightning_Bolt,
      // ParticleType.Wind,
    ].contains(particleType);
    particle.emitsLight = false;
    particle.delay = delay;

    if (speed > 0){
      particle.vx = adj(angle, speed);
      particle.vy = opp(angle, speed);
    } else {
      particle.vx = 0;
      particle.vy = 0;
    }

    particle.vz = zv;
    particle.weight = weight;
    particle.duration = duration;
    particle.durationTotal = duration;
    particle.scale = scale;
    particle.scaleVelocity = scaleV;
    particle.rotation = rotation;
    particle.rotationVelocity = rotationV;
    particle.bounciness = bounciness;
    return particle;
  }

  void spawnParticleWaterDrop({
    required double x,
    required double y,
    required double z,
    required double zv,
    int duration = 30,
  }) {
    spawnParticle(
        particleType: ParticleType.Water_Drop,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0.5,
        zv: zv,
        weight: 3.5,
        duration: duration,
        rotation: 0,
        rotationV: 0,
        scaleV: 0,
        // frictionAir: 0.98,
    );
  }

  void spawnBlood({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    spawnParticle(
      particleType: ParticleType.Blood,
      x: x,
      y: y,
      z: z,
      zv: randomBetween(2, 3),
      angle: angle,
      speed: speed,
      weight: 5,
      duration: 200,
      rotation: 0,
      rotationV: 0,
      scale: 0.6,
      scaleV: 0,
      bounciness: 0,
      // frictionAir: 0.98,
    );
  }

  Particle emitSmoke({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double scaleV = 0.01,
  }) =>
      spawnParticle(
        particleType: ParticleType.Smoke,
        x: x,
        y: y,
        z: z,
        zv: 0,
        angle: 0,
        rotation: 0,
        rotationV: giveOrTake(0.025),
        speed: 0,
        scaleV: scaleV,
        weight: -0.15,
        duration: duration,
        scale: scale,
        // frictionAir: 0.99,
      );

  void spawnParticleShotSmoke({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed,
    int delay = 0,
  }) => spawnParticle(
    particleType: ParticleType.Gunshot_Smoke,
    x: x,
    y: y,
    z: z,
    angle: angle,
    speed: speed,
    zv: 0.32,
    weight: 0.0,
    duration: 120,
    scale: 0.35 + giveOrTake(0.15),
    scaleV: 0.0015,
    // frictionAir: 1.0,
  )..delay = delay;

  void spawnParticleRockShard(double x, double y){
    spawnParticle(
      particleType: ParticleType.Rock,
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

  void spawnParticleTreeShard(double x, double y, double z){
    spawnParticle(
      particleType: ParticleType.Tree_Shard,
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

  void spawnParticleBlockWood(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        particleType: ParticleType.Block_Wood,
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
      );
    }
  }

  void spawnParticleConfettiByType(double x, double y, double z, int type) {
    spawnParticle(
      particleType: type,
      x: x,
      y: y,
      z: z,
      zv: randomBetween(0, 1),
      angle: randomAngle(),
      speed: randomBetween(0.5, 1.0),
      weight: -0.02,
      scale: 0.5,
      duration: randomInt(25, 150),
      delay: randomInt(0, 10),
    );
  }

  void spawnParticleBlockGrass(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        particleType: ParticleType.Block_Grass,
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
      );
    }
  }

  void spawnParticleBlockBrick(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        particleType: ParticleType.Block_Brick,
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
      );
    }
  }

  void spawnParticleBlockSand(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        particleType: ParticleType.Block_Sand,
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
      );
    }
  }

  void spawnParticleLightEmission({
    required double x,
    required double y,
    required double z,
    required int color,
    required double intensity,
  }) =>
      spawnParticle(
        particleType: ParticleType.Light_Emission,
        x: x,
        y: y,
        z: z,
        angle: 0,
        speed: 0,
        weight: 0,
        duration: 35,
      )
        ..flash = true
        ..emissionIntensity = intensity
        ..emissionColor = color;

  void spawnParticleConfetti(double x, double y, double z) {
    spawnParticle(
      particleType: ParticleType.Confetti,
      x: x,
      y: y,
      z: z,
      angle: randomAngle(),
      speed: randomBetween(0.5, 2.0),
      weight: -0.02,
      scale: 0.5,
      duration: 40,
      delay: randomInt(0, 8),
    );
  }

  int get countActiveParticles => activated.length;

  int get countDeactiveParticles => deactivated.length;

  void activateParticle(Particle particle){
      deactivated.remove(particle);
      activated.add(particle);
      particle.deactivating = false;
  }

  void deactivateParticle(Particle particle){
    particle.deactivate();
    activated.remove(particle);
    if (particle is! ParticleRoam){
      deactivated.add(particle);
    }
  }

  void onComponentUpdate() {

    if (options.charactersEffectParticles){
      applyCharactersToParticles();
    }

    final scene = this.scene;
    final activeParticles = this.activated;
    final wind = environment.wind.value;

    windStrength = wind * windStrengthMultiplier;
    windy = wind != 0;
    maxVelocity = 0.3 * wind;

    if (!windy && nextMystEmission-- <= 0) {
      nextMystEmission = 30;
      spawnMystAtMystIndexes();
    }

    if (nextEmissionWaterDrop-- <= 0) {
      nextEmissionWaterDrop = 60;
      spawnWaterDropLargeAtIndexes();
    }

    nextParticleFrame--;

    if (nextParticleFrame <= 0){

      nextParticleFrame = IsometricConstants.Frames_Per_Particle_Animation_Frame;

      for (final particle in activeParticles) {
        particle.frame++;
      }
    }

    final engine = this.engine;
    const padding = 50;
    final minX = engine.Screen_Left - padding;
    final maxX = engine.Screen_Right + padding;
    final minY = engine.Screen_Top - padding;
    final maxY = engine.Screen_Bottom + padding;
    final nodeVisibility = scene.nodeVisibility;
    final sceneLengthRows = scene.lengthRows;
    final sceneLengthColumns = scene.lengthColumns;
    final sceneLengthZ = scene.lengthZ;

    final sceneArea = scene.area;
    final sceneColumns = scene.totalColumns;
    final nodeOrientations = scene.nodeOrientations;
    var totalActiveParticles = activeParticles.length;

    for (var i = 0; i < totalActiveParticles; i++) {
      final particle = activeParticles[i];

      if (particle.deactivating){
        deactivateParticle(particle);
        i--;
        totalActiveParticles--;
        continue;
      }

      particle.cacheSortOrder();
      final dstX = particle.renderX;
      if (dstX < minX || dstX > maxX){
        particle.onscreen = false;
      } else {
        final dstY = particle.renderY;
        if (dstY < minY || dstY > maxY){
          particle.onscreen = false;
        } else {
          particle.onscreen = true;
        }
      }

      final x = particle.x;
      final y = particle.y;
      final z = particle.z;

      if (
        x < 0 ||
        y < 0 ||
        z < 0 ||
        x >= sceneLengthRows ||
        y >= sceneLengthColumns ||
        z >= sceneLengthZ
      ){
        particle.deactivate();
        continue;
      }

      final indexX = x ~/ Node_Size;
      final indexY = y ~/ Node_Size;
      final indexZ = z ~/ Node_Size_Half;

      final index = (indexZ * sceneArea) + (indexX * sceneColumns) + indexY;

      if (nodeVisibility[index] == NodeVisibility.invisible && particle.onscreen){
        particle.onscreen = false;
      }

      final nodeOrientation = nodeOrientations[index];

      particle.nodeIndex = index;
      updateParticle(particle, scene, index, nodeOrientation);
    }
  }

  void spawnMystAtMystIndexes() {
     final mystIndexes = this.mystIndexes;
    for (final index in mystIndexes) {
      spawnMystAtIndex(index);
    }
  }

  void spawnWaterDropLargeAtIndexes() {
     final indexes = this.indexesWaterDrops;
    for (final index in indexes) {
      spawnWaterDropLarge(index);
    }
  }

  // TODO Optimize
  void updateParticle(
      Particle particle,
      IsometricScene scene,
      int index,
      int nodeOrientation,
  ) {
    if (particle.delay > 0) {
      particle.delay--;
      return;
    }

    final particleType = particle.type;

    if (particleType == ParticleType.Wind){
       final vHorizontal = (-(1.0 - parabola(particle.duration01)) * 10) + 2.5;
       particle.vx = vHorizontal;
       particle.vy = -vHorizontal;
    }

    if (particleType == ParticleType.Light_Emission){
      const change = 0.125;
      if (particle.flash){
        particle.emissionIntensity += change;
        if (particle.emissionIntensity >= 1){
          particle.emissionIntensity = 1.0;
          particle.flash = false;
        }
        return;
      }
      particle.emissionIntensity -= change;
      if (particle.emissionIntensity <= 0){
        particle.emissionIntensity = 0;
        particle.deactivate();
      }
      return;
    }

    final particleDuration = particle.duration;
    if (particleDuration > 0) {
      particle.duration--;
      if (particleDuration - 1 == 0){
        particle.deactivate();
        return;
      }
    }

    assert (index >= 0);
    assert (index < scene.totalNodes);

    final nodeCollision = nodeOrientation != NodeOrientation.None && particle.nodeCollidable;

    if (nodeCollision) {
      if (particle.deactiveOnNodeCollision){

        if (particleType == ParticleType.Water_Drop_Large){
          final x = particle.x;
          final y = particle.y;
          final z = particle.z;
          audio.play(audio.waterDrop, x, y, z, maxDistance: 300, volume: 0.6);
          for (var i = 0; i < 3; i++) {
            spawnParticleWaterDrop(
                x: x,
                y: y,
                z: z + 5,
                zv: 2,
            );
          }
        }

        particle.deactivate();
        return;
      }
      particle.z = (particle.indexZ + 1) * Node_Height;
      particle.applyFloorFriction();

    } else {
      particle.applyAirFriction();
      particle.applyGravity();
      if (windy && particle.blownByWind) {
        particle.vx = clamp(particle.vx - windStrength, -maxVelocity, maxVelocity);
        particle.vy = clamp(particle.vy + windStrength, -maxVelocity, maxVelocity);
      }
    }

    final bounce = nodeCollision && particle.vz < 0;
    particle.applyMotion();

    if (bounce) {
      if (nodeOrientation == NodeType.Water){
        return particle.deactivate();
      }
      if (particle.vz < -0.1){
        particle.vz = -particle.vz * particle.bounciness;
      } else {
        particle.vz = 0;
      }
    }
    particle.update(this);
  }

  void sort(){
    if (activatedSorted) return;
    activated.sort(Particle.compare);
  }

  bool get activatedSorted {
    final activated = this.activated;
    final length = activated.length;

    if (length <= 1){
      return true;
    }

    var sortA = activated.first.sortOrderCached;

    for (var i = 1; i < length; i++){
      final sortI = activated[i].sortOrderCached;
      if (sortA > sortI){
        return false;
      }
      sortA = sortI;
    }

    return true;
  }

  void spawnWhisp({
    required double x,
    required double y,
    required double z,
  }) => activated.add(ParticleWhisp(x: x, y: y, z: z));

  void spawnGlow({
    required double x,
    required double y,
    required double z,
  }) => activated.add(
      ParticleGlow(
          x: x,
          y: y,
          z: z,
          color: randomItem(whispColors),
      )
        ..emissionIntensity = 0.5
        ..movementSpeed = 0.7
  );

  ParticleFlying spawnFlying({
    required double x,
    required double y,
    required double z,
  }) {
    final instance = ParticleFlying(
      x: x,
      y: y,
      z: z,
    );
    activated.add(instance);
    return instance;
  }

  void spawnMystAtIndex(int index) {
    const radius = 100.0;
    final scene = this.scene;
    spawnParticle(
        particleType: ParticleType.Myst,
        x: scene.getIndexPositionX(index) + giveOrTake(radius),
        y: scene.getIndexPositionY(index) + giveOrTake(radius),
        z: scene.getIndexPositionZ(index),
        angle: randomAngle(),
        speed: 0.05,
        weight: 0,
        duration: 1000,
        rotationV: giveOrTake(0.005),
    )..nodeCollidable = false;
  }

  void spawnWaterDropLarge(int index) {
    final scene = this.scene;
    const radius = 5.0;
    spawnParticle(
        particleType: ParticleType.Water_Drop_Large,
        x: scene.getIndexPositionX(index) + giveOrTake(radius),
        y: scene.getIndexPositionY(index) + giveOrTake(radius),
        z: scene.getIndexPositionZ(index),
        angle: 0,
        speed: 0,
        weight: 1,
        duration: 1000,
        rotationV: 0,
    )
       ..vz = 0
       ..deactiveOnNodeCollision = true
      ..nodeCollidable = true;
  }

  void spawnTrail(double x, double y, double z, {required int color}) => spawnParticle(
         particleType: ParticleType.Trail,
         x: x,
         y: y,
         z: z,
         weight: 0.04,
         duration: 120,
     )..nodeCollidable = false
      ..emissionColor = color;

  void spawnLightningBolt(double x, double y, double z) {
    spawnParticle(
        particleType: ParticleType.Lightning_Bolt,
        x: x,
        y: y,
        z: z,
        duration: 20,
    );
  }

  void applyCharactersToWind() {
    final windIndexes = this.windIndexes;

    if (windIndexes.isEmpty){
      return;
    }

    final scene = this.scene;
    final totalCharacters = scene.totalCharacters;
    final characters = scene.characters;
    final getIndexPosition = scene.getIndexPosition;

    for (var i = 0; i < totalCharacters; i++){
      final character = characters[i];
      if (character.state == CharacterState.Running) {
        final characterIndex = getIndexPosition(character);
        final characterDirection = character.direction;
        var wind = windIndexes[characterIndex];

        int accelerationX;
        int accelerationY;

        switch (characterDirection) {
          case IsometricDirection.North:
            accelerationX = -4;
            accelerationY = 0;
            break;
          case IsometricDirection.North_East:
            accelerationX = -2;
            accelerationY = -2;
            break;
          case IsometricDirection.East:
            accelerationX = 0;
            accelerationY = -4;
            break;
          case IsometricDirection.South_East:
            accelerationX = 2;
            accelerationY = -2;
            break;
          case IsometricDirection.South:
            accelerationX = -4;
            accelerationY = 0;
            break;
          case IsometricDirection.South_West:
            accelerationX = -2;
            accelerationY = -2;
            break;
          case IsometricDirection.West:
            accelerationX = 0;
            accelerationY = 4;
            break;
          case IsometricDirection.North_West:
            accelerationX = 2;
            accelerationY = 2;
            break;
          default:
            throw Exception('unsupported direction: $characterDirection');
        }

        if (accelerationX != 0) {
           final currentAccelerationX = Wind.getAccelerationX(wind);
           wind = Wind.setAccelerationX(wind, accelerationX + currentAccelerationX);
        }

        if (accelerationY != 0) {
           final currentAccelerationY = Wind.getAccelerationY(wind);
           wind = Wind.setAccelerationX(wind, accelerationY + currentAccelerationY);
        }

        windIndexes[characterIndex] = wind;
      }
    }
  }

  void applyCharactersToParticles() {

    final characters = scene.characters;
    final totalCharacters = scene.totalCharacters;
    final particles = this.activated;

    for (var i = 0; i < totalCharacters; i++){
      final character = characters[i];

      if (character.state == CharacterState.Running) {
        final characterX = character.x;
        final characterY = character.y;
        final characterZ = character.z;

        for (final particle in particles) {
          if (!const [
            ParticleType.Myst,
            ParticleType.Whisp,
          ].contains(particle.type)) {
            continue;
          }

          final distanceSquared = getDistanceXYZSquared(
            characterX,
            characterY,
            characterZ,
            particle.x,
            particle.y,
            particle.z,
          );

          if (distanceSquared == 0){
            continue;
          }

          const minDistance = 200;
          const minDistanceSquare = minDistance * minDistance;

          if (distanceSquared > minDistanceSquare){
            continue;
          }

          final angle = (particle.getAngle(characterX, characterY) + pi) % pi2;
          particle.addForce(
              speed: 5 / distanceSquared,
              angle: angle,
          );
        }
      }
    }
  }

  void bootstrap() {
    final charactersEffectParticles = options.charactersEffectParticles;
    options.charactersEffectParticles = false;
    for (var i = 0; i < 500; i++) {
      onComponentUpdate();
    }
    options.charactersEffectParticles = charactersEffectParticles;
  }
}

class WindNode {
  static int getDirection(int value){
    return value & 0xFF;
  }

  static int getValue(int value){
    return value & 0xFF;
  }

}

class NodeDirection {
  static const north = 0;
  static const northEast = 1;
  static const east = 2;
  static const southEast = 3;
  static const south = 4;
  static const southWest = 5;
  static const west = 6;
  static const northWest = 7;
}