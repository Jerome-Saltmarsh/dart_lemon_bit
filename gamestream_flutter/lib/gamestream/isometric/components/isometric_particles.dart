
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_butterfly.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_glow.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'dart:math';
import 'package:gamestream_flutter/packages/lemon_components.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_whisp.dart';
import 'package:lemon_math/src.dart';

import '../../../isometric/classes/particle.dart';
import 'isometric_component.dart';

class IsometricParticles with IsometricComponent implements Updatable {

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

  final children = <Particle>[];

  final mystIndexes = <int>[];

  var nextMystEmission = 0;

  int get bodyPartDuration =>  randomInt(120, 200);

  Particle getInstance() {
    for (final particle in children) {
      if (!particle.active)
        return particle;
    }

    final instance = Particle();
    instance.active = true;
    children.add(instance);
    return instance;
  }

  void clearParticles(){
    print('particles.clearParticles()');
    children.clear();
  }

  Particle spawnParticle({
    required int type,
    required double x,
    required double y,
    required double z,
    required double frictionAir,
    required bool blownByWind,
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
    bool animation = false,
    int delay = 0,
  }) {
    assert(duration > 0);
    assert (frictionAir >= 0 && frictionAir <= 1.0);
    final particle = getInstance();
    particle.type = type;
    particle.frictionAir = frictionAir;
    particle.blownByWind = blownByWind;
    particle.x = x;
    particle.y = y;
    particle.z = z;
    particle.active = true;
    particle.deactiveOnNodeCollision = const [
       ParticleType.Blood,
       ParticleType.Water_Drop,
    ].contains(type);

    if (particle.deactiveOnNodeCollision){
      particle.nodeCollidable = true;
    }

    particle.animation = animation;
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
    particle.duration = 0;
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
        type: ParticleType.Water_Drop,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0.5,
        zv: zv,
        weight: 5,
        duration: duration,
        rotation: 0,
        rotationV: 0,
        scaleV: 0,
        frictionAir: 0.98,
        blownByWind: true,
    );
  }


  void spawnParticleArm({
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
      duration:  randomInt(120, 200),
      rotation: giveOrTake(pi),
      rotationV: giveOrTake(0.25),
      scale: 0.75,
      scaleV: 0,
      frictionAir: 1.0,
      blownByWind: false,
    );
  }

  void spawnParticleOrgan({
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
        blownByWind: false,
        angle: angle,
        speed: speed,
        zv: randomBetween(0.04, 0.06),
        weight: 6,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 1,
        frictionAir: 1.0,
        scaleV: 0);
  }

  void spawnBlood({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    spawnParticle(
      type: ParticleType.Blood,
      x: x,
      y: y,
      z: z,
      blownByWind: true,
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
      frictionAir: 0.98,
    );
  }

  void spawnParticleShell(
      double x,
      double y,
      double z,
      ) {
    spawnParticle(
      type: ParticleType.Shell,
      blownByWind: false,
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
      frictionAir: 0.98,
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
        type: ParticleType.Smoke,
        blownByWind: true,
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
        frictionAir: 0.99,
      );

  void spawnParticleShotSmoke({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed,
    int delay = 0,
  }) => spawnParticle(
    type: ParticleType.Gunshot_Smoke,
    blownByWind: true,
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
    frictionAir: 1.0,
  )..delay = delay;

  void spawnParticleRockShard(double x, double y){
    spawnParticle(
      type: ParticleType.Rock,
      blownByWind: false,
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
      frictionAir: 0.98,
    );
  }

  void spawnParticleTreeShard(double x, double y, double z){
    spawnParticle(
      type: ParticleType.Tree_Shard,
      blownByWind: false,
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
      frictionAir: 0.98,
    );
  }

  void spawnParticleBlockWood(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Wood,
        blownByWind: false,
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
        frictionAir: 0.98,
      );
    }
  }

  void spawnParticleConfettiByType(double x, double y, double z, int type) {
    spawnParticle(
      type: type,
      x: x,
      y: y,
      z: z,
      blownByWind: false,
      zv: randomBetween(0, 1),
      angle: randomAngle(),
      speed: randomBetween(0.5, 1.0),
      weight: -0.02,
      scale: 0.5,
      duration: randomInt(25, 150),
      delay: randomInt(0, 10),
      frictionAir: 0.98,
    );
  }

  void spawnParticleBlockGrass(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Grass,
        x: x,
        y: y,
        z: z,
        blownByWind: false,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        frictionAir: 0.98,
      );
    }
  }

  void spawnParticleBlockBrick(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Brick,
        x: x,
        y: y,
        z: z,
        blownByWind: false,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        frictionAir: 0.98,
      );
    }
  }

  void spawnParticleBlockSand(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Sand,
        x: x,
        y: y,
        z: z,
        blownByWind: false,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        frictionAir: 0.98,
      );
    }
  }

  void spawnParticleHeadZombie({
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
      blownByWind: false,
      angle: angle,
      speed: speed,
      zv: 0.06,
      weight: 6,
      duration: bodyPartDuration,
      rotation: 0,
      rotationV: 0.05,
      scale: 0.75,
      scaleV: 0,
      frictionAir: 0.98,
    );
  }

  void spawnParticleOrbShard({
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
      blownByWind: false,
      angle: angle,
      rotation: angle,
      speed: speed,
      scaleV: 0,
      weight: 0,
      duration: duration,
      scale: scale,
      frictionAir: 0.98,
    );
  }

  void spawnParticleLegZombie({
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
        blownByWind: false,
        angle: angle,
        speed: speed,
        zv: randomBetween(0, 0.03),
        weight: 6,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        frictionAir: 0.98,
        scale: 0.75);

  }

  void spawnParticleBubble({
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
      blownByWind: true,
      angle: angle,
      rotation: 0,
      speed: speed,
      scaleV: 0,
      weight: -0.5,
      duration: duration,
      scale: scale,
      frictionAir: 0.98,
    );
  }

  void spawnParticleBubbles({
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


  void spawnBubbles(double x, double y, double z, {int amount = 5}){
    for (var i = 0; i < amount; i++) {
      spawnParticleBubble(x: x + giveOrTake(5), y: y + giveOrTake(5), z: z, speed: 1, angle: randomAngle());
    }
  }

  void spawnParticleFirePurple({
    required double x,
    required double y,
    required double z,
    int duration = 60,
    double scale = 1.0,
    double speed = 0.0,
    double angle = 0.0,
  }) {
    spawnParticle(
      type: ParticleType.Fire_Purple,
      blownByWind: false,
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
      frictionAir: 0.98,
    );
  }

  void spawnParticleLightEmission({
    required double x,
    required double y,
    required double z,
    required int color,
    required double intensity,
  }) =>
      spawnParticle(
        type: ParticleType.Light_Emission,
        blownByWind: false,
        x: x,
        y: y,
        z: z,
        angle: 0,
        speed: 0,
        weight: 0,
        duration: 35,
        animation: true,
        frictionAir: 0.98,
      )
        ..flash = true
        ..emissionIntensity = intensity
        ..emissionColor = color;


  void spawnParticleBulletRing({
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
      blownByWind: false,
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
      frictionAir: 0.98,
    );
  }

  void spawnParticleStrikeBlade({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Blade,
      blownByWind: false,
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
      animation: true,
      frictionAir: 0.98,
    );
  }

  void spawnParticleStrikePunch({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Punch,
      blownByWind: false,
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
      animation: true,
      frictionAir: 0.98,
    );
  }

  void spawnParticleStrikeBulletLight({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Light,
      blownByWind: false,
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
      animation: true,
      frictionAir: 0.98,
    );
  }

  void spawnParticleStrikeBullet({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Bullet,
      blownByWind: false,
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
      animation: true,
      frictionAir: 0.98,
    );
  }

  void spawnParticleAnimation({
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
        blownByWind: false,
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
        animation: true,
        frictionAir: 0.98,
      );

  void spawnParticleStarExploding({
    required double x,
    required double y,
    required double z,
  }) {
    spawnParticle(
        type: ParticleType.Star_Explosion,
      blownByWind: false,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0,
        weight: 0,
        duration: 100,
        scale: 0.75,
        frictionAir: 0.98,
    );
  }

  void spawnParticleConfetti(double x, double y, double z) {
    spawnParticle(
      type: randomItem(const[
        ParticleType.Confetti_Red,
        ParticleType.Confetti_Yellow,
        ParticleType.Confetti_Blue,
        ParticleType.Confetti_Green,
        ParticleType.Confetti_Purple,
      ]),
      x: x,
      y: y,
      z: z,
      blownByWind: false,
      angle: randomAngle(),
      speed: randomBetween(0.5, 2.0),
      weight: -0.02,
      scale: 0.5,
      duration: 40,
      delay: randomInt(0, 8),
      frictionAir: 0.98,
    );
  }

  int get countActiveParticles =>
      children.where((element) => element.active).length;

  int get countDeactiveParticles =>
      children.where((element) => !element.active).length;

  void onComponentUpdate() {

    final scene = this.scene;
    final children = this.children;
    final wind = environment.wind.value;

    windStrength = wind * windStrengthMultiplier;
    windy = wind != 0;
    maxVelocity = 0.3 * wind;

    if (!windy && nextMystEmission-- <= 0) {
      nextMystEmission = 30;
      for (final index in mystIndexes) {
        spawnMystAtIndex(index);
      }
    }

    nextParticleFrame--;

    if (nextParticleFrame <= 0){

      nextParticleFrame = IsometricConstants.Frames_Per_Particle_Animation_Frame;

      for (final particle in children) {
        if (!particle.active)
          continue;

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
    final totalParticles = children.length;

    for (var i = 0; i < totalParticles; i++) {
      final particle = children[i];

      if (!particle.active){
        continue;
      }

      final dstX = particle.renderX;
      if (dstX < minX || dstX > maxX){
        particle.onscreen = false;
      } else {
        final dstY = particle.renderY;
        if (dstY < minY || dstY > maxY){
          particle.onscreen = false;
        } else if (nodeVisibility[particle.nodeIndex] == Visibility.invisible){
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
      final nodeOrientation = nodeOrientations[index];

      particle.nodeIndex = index;
      updateParticle(particle, scene, index, nodeOrientation);
    }
  }

  // TODO Optimize
  void updateParticle(
      Particle particle,
      IsometricScene scene,
      int index,
      int nodeOrientation,
  ) {
    assert (particle.active);

    if (particle.delay > 0) {
      particle.delay--;
      return;
    }

    if (particle.type == ParticleType.Light_Emission){
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

    assert (index >= 0);
    assert (index < scene.totalNodes);

    final nodeCollision = nodeOrientation != NodeOrientation.None && particle.nodeCollidable;

    if (nodeCollision) {
      if (particle.deactiveOnNodeCollision){
        particle.deactivate();
        return;
      }
      particle.z = (particle.indexZ + 1) * Node_Height;
      particle.applyFloorFriction();

    } else {
      particle.applyAirFriction();
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
    children.sort(Particle.compare);
  }

  void spawnWhisp({
    required double x,
    required double y,
    required double z,
  }) => children.add(ParticleWhisp(x: x, y: y, z: z));

  void spawnGlow({
    required double x,
    required double y,
    required double z,
  }) => children.add(
      ParticleGlow(
          x: x,
          y: y,
          z: z,
          color: randomItem(whispColors),
      )
        ..emissionIntensity = 0.5
        ..movementSpeed = 0.7
  );

  void spawnButterfly({
    required double x,
    required double y,
    required double z,
  }) => children.add(
      ParticleButterfly(
          x: x,
          y: y,
          z: z,
      )
  );

  void spawnMystAtIndex(int index) {
    const radius = 100.0;
    spawnParticle(
        type: ParticleType.Myst,
        blownByWind: true,
        x: scene.getIndexPositionX(index) + giveOrTake(radius),
        y: scene.getIndexPositionY(index) + giveOrTake(radius),
        z: scene.getIndexPositionZ(index),
        angle: randomAngle(),
        speed: 0.05,
        weight: 0,
        duration: 1000,
        frictionAir: 1.00,
        rotationV: giveOrTake(0.005),
    )..nodeCollidable = false;
  }

  void spawnTrail(double x, double y, double z, {required int color}) => spawnParticle(
         type: ParticleType.Trail,
         x: x,
         y: y,
         z: z,
         frictionAir: 0,
         weight: 0.04,
         duration: 120,
         blownByWind: false,
     )..nodeCollidable = false
      ..emissionColor = color;
}