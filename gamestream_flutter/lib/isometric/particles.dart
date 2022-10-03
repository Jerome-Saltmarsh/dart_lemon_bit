
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/particle_type.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/update.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import 'classes/vector3.dart';
import 'effects.dart';
import 'grid_state_util.dart';

final particles = <Particle>[];
var totalActiveParticles = 0;
var totalParticles = 0;

void sortParticlesActive(){
  totalParticles = particles.length;
  for (var pos = 1; pos < totalParticles; pos++) {
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

void sortParticles(){
  sortParticlesActive();
  totalActiveParticles = 0;
  totalParticles = particles.length;
  for (; totalActiveParticles < totalParticles; totalActiveParticles++){
      if (!particles[totalActiveParticles].active) break;
  }

  if (totalActiveParticles == 0) return;
  
  assert(verifyTotalActiveParticles());

  insertionSort(
    particles,
    compare: _compareParticles,
    end: totalActiveParticles,
  );
}

int _compareParticles(Particle a, Particle b) {
    return a.renderOrder > b.renderOrder ? 1 : -1;
}

/// do this during the draw call so that particles are smoother
void updateParticles() {
  for(final particle in particles){
    _updateParticle(particle);
  }
  updateParticleFrames();
}

void updateParticlesZombieParts() {
  if (engine.frame % 6 != 0) return;
  for (var i = 0; i < totalActiveParticles; i++) {
    final particle = particles[i];
    if (!particle.active) break;
    if (!particleEmitsBlood(particle.type)) continue;
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

bool particleEmitsBlood(int type){
  if (type == ParticleType.Zombie_Head) return true;
  if (type == ParticleType.Zombie_Torso) return true;
  if (type == ParticleType.Zombie_Arm) return true;
  if (type == ParticleType.Zombie_leg) return true;
  return false;
}

void _updateParticle(Particle particle) {
  if (!particle.active) return;
  if (particle.outOfBounds) return particle.deactivate();

  if (particle.animation) {
    if (particle.duration-- <= 0)
      particle.deactivate();
    return;
  }

  final nodeIndex = gridNodeIndexVector3(particle);
  final tile = gridNodeTypes[nodeIndex];
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

int get bodyPartDuration => randomInt(120, 200);

void spawnParticleWaterDrop({
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
  );
}

void spawnParticleDustCloud({
  required double x,
  required double y,
  required double z,
}) {
  spawnParticle(
    type: ParticleType.Dust,
    x: x,
    y: y,
    z: z,
    zv: 0,
    angle: 0,
    speed: 0,
    weight: -0.25,
    duration: 300,
    rotation: 0,
    bounciness: 0,
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

void spawnParticleShell(
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
    bounciness: 0.35,
  );
}

void spawnParticleBlockWood(double x, double y, double z, [int count = 3]){
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

void spawnParticleBlockGrass(double x, double y, double z, [int count = 3]){
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


void spawnParticleBlockBrick(double x, double y, double z, [int count = 3]){
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
}) {
  print("spawnParticleFlame()");
  spawnParticle(
      type: ParticleType.Flame,
      x: x,
      y: y,
      z: z,
      angle: 0,
      speed: 0,
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
    rotation: randomAngle(),
    rotationV: 0,
    scale: 0.3,
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

void spawnParticleBubbleV3(Vector3 value, {
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
    angle: angle,
    rotation: 0,
    speed: speed,
    scaleV: 0,
    weight: -0.5,
    duration: duration,
    scale: scale,
  );
}


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

void spawnParticleCutGrass({
  required double x,
  required double y,
  required double z,
  int duration = 100,
  double scale = 1.0,
  double angle = 0,
  double speed = 0,
}) {
  spawnParticle(
    type: ParticleType.Cut_Grass,
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
    checkCollision: false
  );
}

void spawnParticleStrikeBlade({
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

void spawnParticleStrikePunch({
  required double x,
  required double y,
  required double z,
  int duration = 100,
  double scale = 1.0,
  double angle = 0,
  double speed = 2,
}) {
  spawnParticle(
    type: ParticleType.Strike_Punch,
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

void spawnParticleSlashCrowbar(
  double x,
  double y,
  double z,
  double angle,
) =>
  spawnParticleAnimation(
    type: ParticleType.Slash_Crowbar,
    x: x,
    y: y,
    z: z,
    angle: angle,
    duration: 50,
    scale: 1.0,
  );

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

void spawnParticleHandgunFiring({
  required double x,
  required double y,
  required double z,
  double angle = 0,
}) {
  spawnParticle(
    type: ParticleType.Handgun_Firing,
    x: x,
    y: y,
    z: z,
    angle: angle,
    rotation: angle,
    speed: 0,
    scaleV: 0,
    weight: 0,
    duration: 7,
    checkCollision: false,
  );
}

void spawnParticleStarExploding({
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

void spawnParticleLightEmission({
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

void spawnParticle({
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

/// This may be the cause of the bug in which the sword particle does not render
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

void spawnParticleFire({
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

void spawnParticleFirePurple({
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


void spawnParticleSlimeDeath({
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