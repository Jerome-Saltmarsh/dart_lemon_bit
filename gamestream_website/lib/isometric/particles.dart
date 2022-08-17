
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import 'effects.dart';

final particles = <Particle>[];
var totalActiveParticles = 0;
var totalParticles = 0;

void sortParticles(){
  insertionSort(
    particles,
    compare: _compareParticlesActive,
  );
  totalActiveParticles = 0;
  totalParticles = particles.length;
  for (; totalActiveParticles < totalParticles; totalActiveParticles++){
      if (!particles[totalActiveParticles].active) break;
  }
  if (totalActiveParticles == 0) return;
  insertionSort(
    particles,
    compare: _compareParticles,
    end: totalActiveParticles,
  );
}

int _compareParticles(Particle a, Particle b) {
  if (a.z == b.z){
    return a.renderOrder > b.renderOrder ? 1 : -1;
  }
  return a.z > b.z ? 1 : -1;
}

int _compareParticlesActive(Particle a, Particle b) {
  if (a.active == b.active) return 0;
  if (a.active) return -1;
  return 1;
}

void updateParticles() {

  for (var i = 0; i < totalActiveParticles; i++) {
    _updateParticle(particles[i]);
  }

  if (engine.frame % 6 == 0) {
    for (var i = 0; i < totalActiveParticles; i++) {
      final particle = particles[i];
      if (!particle.active) break;
      if (!particle.bleeds) continue;
      if (particle.speed < 2.0) continue;
      spawnParticleBlood(
        x: particle.x,
        y: particle.y,
        z: particle.z,
        zv: 0,
        angle: 0,
        speed: 0,
      );
    }
  }
}


void _updateParticle(Particle particle){
  if (!particle.active) return;
  if (particle.outOfBounds) return particle.deactivate();

  final tile = particle.tile.type;
  final airBorn =
      tile == GridNodeType.Empty        ||
      tile == GridNodeType.Rain_Landing ||
      tile == GridNodeType.Rain_Falling ||
      tile == GridNodeType.Grass_Long ||
      tile == GridNodeType.Fireplace    ;

  if (!airBorn) {
    particle.deactivate();
    return;
  }

  if (!airBorn){
    particle.z = (particle.indexZ + 1) * tileHeight;
    particle.applyFloorFriction();
  } else {
    final wind = particle.wind * 0.01;
    particle.xv -= wind;
    particle.yv += wind;
  }
  final bounce = particle.zv < 0 && !airBorn;
  particle.updateMotion();

  if (particle.outOfBounds) return particle.deactivate();

  if (bounce) {
    if (tile == GridNodeType.Water){
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
}

int get bodyPartDuration => randomInt(120, 200);

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
    duration: bodyPartDuration,
    rotation: giveOrTake(pi),
    rotationV: giveOrTake(0.25),
    scale: 0.75,
    scaleV: 0,
    castShadow: true,
  );
}

void spawnParticleBlood({
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
    weight: 6,
    duration: randomInt(120, 200),
    rotation: 0,
    rotationV: 0,
    scale: 0.6,
    scaleV: 0,
    bounciness: 0,
    castShadow: true,
  );
}

void spawnParticleLeaf({
  required double x,
  required double y,
  required double z,
  required double zv,
  required double angle,
  required double speed
}) {
  spawnParticle(
    type: ParticleType.Leaf,
    x: x,
    y: y,
    z: z,
    zv: zv,
    angle: angle,
    speed: speed,
    weight: 1,
    duration: randomInt(120, 200),
    rotation: 0,
    rotationV: 0,
    scale: 0.6,
    scaleV: 0,
    bounciness: 0,
    castShadow: true,
  );
}

void spawnParticleFireYellow({
  required double x,
  required double y,
  required double z,
  required double zv,
  required double angle,
  required double speed
}){
  const type = ParticleType.FireYellow;
  spawnParticle(
      type: type,
      x: x,
      y: y,
      z: 0,
      angle: angle,
      speed: speed,
      weight: 0,
      duration: randomInt(10, 25),
      scale: 1,
      scaleV: 0.035
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

void spawnParticleShell({
  required double x,
  required double y,
}) {
  final type = ParticleType.Shell;
  spawnParticle(
    type: type,
    x: x,
    y: y,
    z: 0.8,
    angle: randomAngle(),
    speed: 1.5,
    zv: 0.075,
    weight: 0.35,
    duration: 1000,
    rotation: randomAngle(),
    rotationV: 0.75,
    scale: 0.3,
    bounciness: 0.4,
    castShadow: true,
  );
}

void spawnParticleShotSmoke({
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

void spawnParticleRockShard(double x, double y){
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
    castShadow: true,
    bounciness: 0.35,
  );
}

void spawnParticleTreeShard(double x, double y, double z){
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
    castShadow: true,
    bounciness: 0.35,
  );
}

void spawnParticleShardWood(double x, double y){
  spawnParticle(
    type: ParticleType.Shard_Wood,
    x: x,
    y: y,
    z: randomBetween(0.0, 0.2),
    angle: randomAngle(),
    speed: randomBetween(0.5, 1.25),
    zv: randomBetween(0.1, 0.2),
    weight: 0.5,
    duration: randomInt(150, 200),
    scale: randomBetween(1.0, 1.75),
    scaleV: 0,
    rotation: randomAngle(),
    castShadow: true,
    bounciness: 0.35,
  );
}

void spawnParticlePotShard(double x, double y){
  spawnParticle(
    type: ParticleType.Pot_Shard,
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
    castShadow: true,
    bounciness: 0.35,
  );
}

void spawnParticleShrapnel({
  required double x,
  required double y,
  required double z,
  required double zv,
  required double angle,
  required double speed
}) {
  spawnParticle(
      type: ParticleType.Shrapnel,
      x: x,
      y: y,
      z: 0,
      angle: angle,
      speed: speed,
      zv: randomBetween(0.1, 0.4),
      weight: 0.5,
      duration: randomInt(150, 200),
      scale: randomBetween(0.6, 1.25),
      scaleV: 0
  );
}


void spawnParticleFlame({
  required double x,
  required double y,
  required double z,
  required double zv,
  required double angle,
  required double speed
}) {
  spawnParticle(
      type: ParticleType.Flame,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: 0.015,
      weight: 0.0,
      duration: 120,
      rotation: 0,
      rotationV: 0,
      scale: 1.0,
      scaleV: 0.005
  );
}

void spawnParticleSmoke({
  required double x,
  required double y,
  required double z,
  required double zv,
  required double angle,
  required double speed
}) {
  spawnParticle(
      type: ParticleType.Smoke,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: 0.015,
      weight: 0.0,
      duration: 120,
      rotation: 0,
      rotationV: 0,
      scale: 0.2,
      scaleV: 0.005);
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
      angle: angle,
      speed: speed,
      zv: 0.06,
      weight: 6,
      duration: bodyPartDuration,
      rotation: 0,
      rotationV: 0.05,
      scale: 0.75,
      scaleV: 0,
      castShadow: true
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
      angle: angle,
      speed: speed,
      zv: randomBetween(0, 0.03),
      weight: 6,
      duration: bodyPartDuration,
      rotation: giveOrTake(pi),
      rotationV: giveOrTake(0.25),
      scale: 0.75);
}

void spawnEffect({
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

void spawnParticleOrb(OrbType type, double x, double y) {
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
    rotation: 0,
    rotationV: 0,
    scale: 0.3,
    // scaleV: -0.01,
  );
}

void spawnExplosion(double x, double y) {
  spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
  audio.explosion(x, y);
  // modules.game.actions.spawnBulletHole(x, y);
  const shrapnelCount = 6;
  for (var i = 0; i < shrapnelCount; i++) {
    spawnParticleShrapnel(x: x, y: y, z: 0.3, zv: 1 + giveOrTake(0.25), angle: randomAngle(), speed: 1 + giveOrTake(0.25));
    spawnParticleSmoke(x: x, y: y, z: 0, zv: 0, angle: randomAngle(), speed: 0.5);
    spawnParticleFlame(x: x, y: y, z: 0, zv: 0, angle: randomAngle(), speed: 0.5);
  }
  for (var i = 0; i < shrapnelCount; i++) {
    spawnParticleFireYellow(x: x, y: y, z: 0.3, zv: 1 + giveOrTake(0.25), angle: randomAngle(), speed: 1 + giveOrTake(0.25));
  }
}

void freezeCircle({
  required double x,
  required double y
}){
  spawnEffect(x: x, y: y, type: EffectType.FreezeCircle, duration: 45);
}


void spawnParticleOrbShard({
  required double x,
  required double y,
  required double z,
  int duration = 12,
  double speed = 1.0,
}) {
  spawnParticle(
    type: ParticleType.Orb_Shard,
    x: x,
    y: y,
    z: z,
    angle: randomAngle(),
    speed: speed,
    scaleV: 0.01,
    weight: 0,
    duration: duration,
  );
}

void spawnParticle({
  required int type,
  required double x,
  required double y,
  required double z,
  required double angle,
  required double speed,
  double zv = 0,
  double weight = 1,
  int duration = 100,
  double scale = 1,
  double scaleV = 0,
  double rotation = 0,
  double rotationV = 0,
  bounciness = 0.5,
  double airFriction = 0.98,
  bool castShadow = false,
}) {
  assert(duration > 0);
  final particle = getParticleInstance();
  assert(!particle.active);
  particle.type = type;
  particle.casteShadow = castShadow;
  particle.x = x;
  particle.y = y;
  particle.z = z;

  if (speed > 0){
    particle.xv = getAdjacent(angle, speed);
    particle.yv = getOpposite(angle, speed);
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

Particle getParticleInstance() {
  totalActiveParticles++;
  if (totalActiveParticles >= totalParticles){
     final instance = Particle();
     particles.add(instance);
     return instance;
  }
  final particle = particles[totalActiveParticles];
  assert (!particle.active);
  return particle;
}

