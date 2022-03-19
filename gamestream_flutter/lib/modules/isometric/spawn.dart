import 'dart:math';

import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/classes/Explosion.dart';
import 'package:gamestream_flutter/classes/FloatingText.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:bleed_common/OrbType.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/randomAngle.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/opposite.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import 'enums.dart';
import 'state.dart';


const Map<ParticleType, double> _particleTypeSize = {
  ParticleType.Zombie_Head: 64.0,
  ParticleType.Blood: 8.0,
  ParticleType.Human_Head: 64.0,
  ParticleType.Myst: 64.0,
  ParticleType.Smoke: 32.0,
  ParticleType.Shrapnel: 32.0,
  ParticleType.Shell: 32.0,
  ParticleType.Organ: 64,
  ParticleType.FireYellow: 32.0,
  ParticleType.Arm: 64,
  ParticleType.Leg: 64,
  ParticleType.Pixel: 8,
  ParticleType.Orb_Ruby: 24.0,
};

class IsometricSpawn {

  final IsometricState state;
  late final particles;
  IsometricSpawn(this.state){
    particles = state.particles;
  }

  int get bodyPartDuration => randomInt(120, 200);

  Particle getAvailableParticle() {
    final value = state.next;
    if (value != null){
      state.next = value.next;
      value.next = null;
      return value;
    }

    final instance = Particle();
    particles.add(instance);
    return instance;
  }

  void _particle({
    required ParticleType type,
    required double x,
    required double y,
    required double angle,
    required double speed,
    double z = 0,
    double zv = 0,
    double weight = 1,
    int duration = 100,
    double scale = 1,
    double scaleV = 0,
    double rotation = 0,
    double rotationV = 0,
    bounciness = 0.5,
    double airFriction = 0.98,
    bool hasShadow = false,
  }) {
    assert(duration > 0);
    final particle = getAvailableParticle();
    particle.size = _particleTypeSize[type] ?? 0;
    particle.type = type;
    particle.hasShadow = hasShadow;
    particle.x = x;
    particle.y = y;
    particle.z = z;

    if (speed > 0){
      particle.xv = adjacent(angle, speed);
      particle.yv = opposite(angle, speed);
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
    particle.rotationV = rotationV;
    particle.bounciness = bounciness;
    particle.airFriction = airFriction;
  }

  void arm({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    _particle(
        type: ParticleType.Arm,
        x: x,
        y: y,
        z: z,
        angle: angle,
        speed: speed,
        zv: randomBetween(0.04, 0.06),
        weight: 0.25,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 0.75,
        scaleV: 0,
        hasShadow: true,
    );
  }

  void blood({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    const type = ParticleType.Blood;
    const weight = 0.135;
    const zero = 0.0;
    const scale = 0.6;
    const durationMin = 120;
    const durationMax = 200;
    const hasShadow = true;

    _particle(
        type: type,
        x: x,
        y: y,
        z: z,
        zv: zv,
        angle: angle,
        speed: speed,
        weight: weight,
        duration: randomInt(durationMin, durationMax),
        rotation: zero,
        rotationV: zero,
        scale: scale,
        scaleV: zero,
        bounciness: zero,
        hasShadow: hasShadow,
    );
  }

  void fireYellow({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
}){
    _particle(
        type: ParticleType.FireYellow,
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

  void headHuman({
        required double x,
        required double y,
        required double z,
        required double zv,
        required double angle,
        required double speed
      }) {
    _particle(
      type: ParticleType.Human_Head,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: randomBetween(0, 0.03),
      weight: 0.25,
      duration: bodyPartDuration,
      rotation: giveOrTake(pi),
      rotationV: giveOrTake(10),
      scale: 1,
      scaleV: 0,
    );
  }

  void organ({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    _particle(
        type: ParticleType.Organ,
        x: x,
        y: y,
        z: z,
        angle: angle,
        speed: speed,
        zv: randomBetween(0.04, 0.06),
        weight: 0.25,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 1,
        scaleV: 0);
  }

  void shell({
    required double x,
    required double y,
  }) {
    const scale = 0.3;
    const duration = 100;
    const weight = 0.35;
    const zVelocity = 0.075;
    const speed = 1.5;
    const height = 0.8;
    const rotationVelocity = 0.01;
    const bounciness = 1.0;

    _particle(
      type: ParticleType.Shell,
      x: x,
      y: y,
      z: height,
      angle: randomAngle(),
      speed: speed,
      zv: zVelocity,
      weight: weight,
      duration: duration,
      rotation: randomAngle(),
      rotationV: rotationVelocity,
      scale: scale,
      bounciness: bounciness,
    );
  }

  void shotSmoke({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    for (int i = 0; i < 4; i++) {
      _particle(
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

  void shrapnel({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    _particle(
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
        scaleV: 0);
  }

  void smoke({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    _particle(
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

  void headZombie({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    _particle(
      type: ParticleType.Zombie_Head,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: 0.06,
      weight: 0.15,
      duration: bodyPartDuration,
      rotation: 0,
      rotationV: 0.05,
      scale: 0.75,
      scaleV: 0,
      hasShadow: true
    );
  }

  void legZombie({
  required double x,
  required double y,
  required double z,
  required double angle,
  required double speed
  }) {
    _particle(
        type: ParticleType.Leg,
        x: x,
        y: y,
        z: z,
        angle: angle,
        speed: speed,
        zv: randomBetween(0, 0.03),
        weight: 0.25,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 0.75);
  }

  Effect getEffect(){
    for(final effect in game.effects){
      if (effect.enabled) continue;
      return effect;
    }
    final effect = Effect();
    game.effects.add(effect);
    return effect;
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

  void orb(OrbType type, double x, double y) {
    _particle(
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

  void explosion(double x, double y) {
    spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
    audio.explosion(x, y);
    modules.game.actions.spawnBulletHole(x, y);
    final shrapnelCount = randomInt(4, 10);
    for (var i = 0; i < shrapnelCount; i++) {
      shrapnel(x: x, y: y, z: 0.3, zv: 1, angle: 1, speed: 1);
    }
    for (var i = 0; i < shrapnelCount; i++) {
      // fireYellow(x, y);
    }
  }

  void freezeCircle({
    required double x,
    required double y
  }){
    spawnEffect(x: x, y: y, type: EffectType.FreezeCircle, duration: 45);
  }

  void spawnFloatingText(double x, double y, dynamic value) {
    for (final text in isometric.state.floatingText) {
      if (text.duration > 0) continue;
      text.duration = game.settings.floatingTextDuration;
      text.x = x;
      text.y = y;
      text.value = value.toString();
      return;
    }
    isometric.state.floatingText.add(FloatingText(
        x: x,
        y: y,
        value: value.toString(),
        duration: game.settings.floatingTextDuration));
  }
}