
import 'dart:math';

import 'package:amulet_client/enums/node_visibility.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_client/classes/particle_flying.dart';
import 'package:amulet_client/classes/particle_glow.dart';
import 'package:amulet_client/classes/particle_roam.dart';
import 'package:amulet_client/classes/particle_whisp.dart';
import 'package:amulet_client/isometric/ui/isometric_colors.dart';
import 'package:amulet_client/components.dart';
import 'package:lemon_math/src.dart';

import '../../classes/particle.dart';
import 'isometric_component.dart';
import 'isometric_scene.dart';

class IsometricParticles with IsometricComponent implements Updatable {

  static const Flame_Duration = 30;
  static const Water_Duration = 50;
  static const Magic_Duration = 50;
  static const windStrengthMultiplier = 0.003;

  var windy = false;
  var windStrength = 0.0;
  var nodeType = 0;

  late final whispColors = [
    IsometricColors.aqua_1.value,
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
    if (deactivated.isNotEmpty){
       final instance = deactivated.removeAt(0);
       instance.deactivating = false;
       activated.add(instance);
       return instance;
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
    double bounciness = 0.5,
    int delay = 0,
  }) {
    assert (duration > 0);

    final particle = getInstance();
    particle.type = particleType;
    particle.frictionAir = ParticleType.frictionAir[particleType] ?? 1.0;
    particle.blownByWind = ParticleType.blownByWind.contains(particleType);
    // particle.deactiveOnNodeCollision = ParticleType.deactivateOnNodeCollision.contains(particleType);
    particle.x = x;
    particle.y = y;
    particle.z = z;

    // if (particle.deactiveOnNodeCollision){
    //   particle.nodeCollidable = true;
    // }

    particle.animation = const [
      ParticleType.Lightning_Bolt,
      // ParticleType.Wind,
    ].contains(particleType);
    particle.emitsLight = false;

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
      weight: 10.0,
      duration: 200,
      rotation: 0.0,
      rotationV: 0.0,
      scale: 0.6,
      scaleV: 0.0,
      bounciness: 0.0,
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
        zv: 0.5,
        angle: 0,
        rotation: 0,
        rotationV: 0,
        speed: 0,
        scaleV: scaleV,
        weight: -0.15,
        duration: duration,
        scale: scale,
        // frictionAir: 0.99,
      );

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
        zv: randomBetween(2, 4),
        weight: 10,
        duration: 25,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0.0,
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
        weight: 10.0,
        duration: 15,
        scale: 0.6,
        scaleV: 0.0,
        rotation: randomAngle(),
        bounciness: 0.0,
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

  void deactivateParticle(Particle particle){
    particle.deactivate();
    activated.remove(particle);
    if (particle is! ParticleRoam){
      deactivated.add(particle);
    }
  }

  @override
  void onComponentUpdate() {

    if (!server.connected){
      return;
    }

    if (this.scene.totalNodes == 0){
      return;
    }

    if (options.charactersEffectParticles){
      applyCharactersToParticles();
    }

    final scene = this.scene;
    final activeParticles = this.activated;
    final wind = environment.wind.value;

    this.windStrength = wind * windStrengthMultiplier;
    this.windy = wind != 0;
    final windy = this.windy;
    final windStrength = this.windStrength;
    final maxVelocity = wind * 1.0;

    if (!windy && nextMystEmission-- <= 0) {
      nextMystEmission = 30;
      spawnMystAtMystIndexes();
    }

    if (nextEmissionWaterDrop-- <= 0) {
      nextEmissionWaterDrop = 60;
      spawnWaterDropLargeAtIndexes();
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

      final x = particle.x;
      final y = particle.y;
      final z = particle.z;

      final dstX = (x - y) * 0.5 ;
      var onscreen = false;

      if (dstX < minX || dstX > maxX){
        particle.onscreen = false;
      } else {
        final dstY = ((x + y) * 0.5) - z;
        if (dstY < minY || dstY > maxY){
          particle.onscreen = false;
        } else {
          particle.onscreen = true;
          onscreen = true;
        }
      }

      particle.sortOrderCached = x + y + z + z;

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

      if (onscreen && nodeVisibility[index] == NodeVisibility.invisible){
        particle.onscreen = false;
      }

      final nodeOrientation = nodeOrientations[index];

      particle.nodeIndex = index;

      if (windy && particle.blownByWind) {
        particle.vx = clamp(particle.vx - windStrength, -maxVelocity, maxVelocity);
        particle.vy = clamp(particle.vy + windStrength, -maxVelocity, maxVelocity);
      }

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

    final particleType = particle.type;

    if (particleType == ParticleType.Wind){
       final vHorizontal = (-(1.0 - pyramid(particle.duration01)) * 10) + 2.5;
       particle.vx = vHorizontal;
       particle.vy = -vHorizontal;
    }

    if (particleType == ParticleType.Light_Emission){
      const change = 0.125;
      if (particle.flash) {
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

    final nodeCollision = nodeOrientation != NodeOrientation.None;

    if (nodeCollision && ParticleType.nodeCollidable.contains(particleType)) {
      if (particleType == ParticleType.Water_Drop_Large) {
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
    } else {

      if (!const [
        ParticleType.Butterfly,
        ParticleType.Whisp,
        ParticleType.Glow,
        ParticleType.Moth,
        ParticleType.Confetti,
        ParticleType.Myst,
        ParticleType.Smoke,
        ParticleType.Shadow,
        ParticleType.Trail,
      ].contains(particleType)) {
        particle.applyAirFriction();
        particle.applyGravity();
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
        ..emissionIntensity = 0.3
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
    );
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
       ..vz = 0;
  }

  void spawnTrail(double x, double y, double z, {required int color}) => spawnParticle(
         particleType: ParticleType.Trail,
         x: x,
         y: y,
         z: z,
         weight: 0.04,
         duration: 120,
     )..emissionColor = color;

  void spawnLightningBolt(double x, double y, double z) {
    spawnParticle(
        particleType: ParticleType.Lightning_Bolt,
        x: x,
        y: y,
        z: z,
        duration: 20,
    );
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

  void emitFlames({
    required double x,
    required double y,
    required double z,
    required int count,
    double scale = 1.0,
    double radius = 5.0,
  }){
    for (var i = 0; i < count; i++){
      emitFlame(
        x: x + giveOrTake(radius),
        y: y + giveOrTake(radius),
        z: z,
      );
    }
  }

  Particle emitFlame({
    required double x,
    required double y,
    required double z,
    double scale = 1.0
  }) =>
      spawnParticle(
        particleType: ParticleType.Flame,
        x: x,
        y: y,
        z: z,
        zv: 1.2,
        angle: 0,
        rotation: 0,
        speed: 0,
        weight: 0,
        scaleV: -(1.0 / Flame_Duration),
        duration: Flame_Duration,
        scale: scale,
      )
        ..emitsLight = false
        ..blownByWind = true
  ;

  Particle emitWater({
    required double x,
    required double y,
    required double z,
    double scale = 1.0
  }) =>
      spawnParticle(
        particleType: ParticleType.Water,
        x: x,
        y: y,
        z: z,
        zv: 0.6,
        angle: 0,
        rotation: 0,
        speed: 0,
        weight: 0,
        scaleV: -(1.0 / Water_Duration),
        duration: Water_Duration,
        scale: scale,
      )
        ..emitsLight = false
        ..blownByWind = true
  ;

  Particle spawnParticleHealth(
    double x,
    double y,
    double z,
  ) =>
      spawnParticle(
        particleType: ParticleType.Health,
        x: x,
        y: y,
        z: z,
        zv: 0.6,
        angle: 0,
        rotation: 0,
        speed: 0,
        weight: 0,
        scaleV: -(1.0 / Water_Duration),
        duration: Water_Duration,
        scale: 1,
      )
        ..emitsLight = false
        ..blownByWind = true
  ;

  Particle spawnParticleMagic(
    double x,
    double y,
    double z,
  ) =>
      spawnParticle(
        particleType: ParticleType.Magic,
        x: x,
        y: y,
        z: z,
        zv: 0.6,
        angle: 0,
        rotation: 0,
        speed: 0,
        weight: 0,
        scaleV: -(1.0 / Water_Duration),
        duration: Water_Duration,
        scale: 1,
      )
        ..emitsLight = false
        ..blownByWind = true
  ;

  Particle emitIce({
    required double x,
    required double y,
    required double z,
    double scale = 1.0
  }) =>
      spawnParticle(
        particleType: ParticleType.Ice,
        x: x,
        y: y,
        z: z,
        zv: 0.6,
        angle: 0,
        rotation: 0,
        speed: 0,
        weight: 0,
        scaleV: -(1.0 / Flame_Duration),
        duration: Flame_Duration,
        scale: scale,
      )
        ..emitsLight = false
        ..blownByWind = true
  ;

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