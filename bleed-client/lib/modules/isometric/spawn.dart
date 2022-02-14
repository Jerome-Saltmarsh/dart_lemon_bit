
import 'dart:math';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';
import 'package:lemon_math/angle.dart';
import 'package:lemon_math/piHalf.dart';

import 'enums.dart';
import 'state.dart';

class IsometricSpawn {

  final IsometricState state;
  IsometricSpawn(this.state);

  Particle getAvailableParticle() {
    for (Particle particle in state.particles) {
      if (particle.active) continue;
      return particle;
    }
    final instance = Particle();
    state.particles.add(instance);
    return instance;
  }

  void _particle({
    required ParticleType type,
    required double x,
    required double y,
    double z = 0,
    double xv = 0,
    double yv = 0,
    double zv = 0,
    double weight = 1,
    int duration = 100,
    double scale = 1,
    double scaleV = 0,
    double rotation = 0,
    double rotationV = 0,
    bounciness = 0.5,
    double airFriction = 0.98
  }) {
    final particle = getAvailableParticle();
    particle.type = type;
    particle.x = x;
    particle.y = y;
    particle.z = z;
    particle.xv = xv;
    particle.yv = yv;
    particle.zv = zv;
    particle.weight = weight;
    particle.duration = duration;
    particle.scale = scale;
    particle.scaleV = scaleV;
    particle.rotation = rotation;
    particle.rotationV = rotationV;
    particle.bounciness = bounciness;
    particle.active = true;
    particle.airFriction = airFriction;
  }

  void arm(double x, double y, double z, {double xv = 0, double yv = 0}) {
    _particle(
        type: ParticleType.Arm,
        x: x,
        y: y,
        z: z,
        xv: xv,
        yv: yv,
        zv: randomBetween(0.04, 0.06),
        weight: 0.25,
        duration: randomInt(90, 150),
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 0.75,
        scaleV: 0);
  }

  void blood(double x, double y, double z,
      {double xv = 0, double yv = 0, double zv = 0}) {
    _particle(
        type: ParticleType.Blood,
        x: x,
        y: y,
        z: z,
        xv: xv,
        yv: yv,
        zv: zv,
        weight: 0.1,
        duration: 200,
        rotation: 0,
        rotationV: 0,
        scale: 0.6,
        scaleV: 0,
        bounciness: 0);
  }

  void fireYellow(double x, double y){
    _particle(
        type: ParticleType.FireYellow,
        x: x,
        y: y,
        z: 0,
        xv: giveOrTake(2),
        yv: giveOrTake(2),
        weight: 0,
        duration: randomInt(10, 25),
        scale: 1,
        scaleV: 0.035
    );
  }

  void headHuman(double x, double y, double z, {double xv = 0, double yv = 0}) {
    _particle(
      type: ParticleType.Human_Head,
      x: x,
      y: y,
      z: z,
      xv: xv,
      yv: yv,
      zv: randomBetween(0, 0.03),
      weight: 0.25,
      duration: randomInt(90, 150),
      rotation: giveOrTake(pi),
      rotationV: giveOrTake(10),
      scale: 1,
      scaleV: 0,
    );
  }

  void organ(double x, double y, double z, {double xv = 0, double yv = 0}) {
    _particle(
        type: ParticleType.Organ,
        x: x,
        y: y,
        z: z,
        xv: xv,
        yv: yv,
        zv: randomBetween(0.04, 0.06),
        weight: 0.25,
        duration: randomInt(90, 150),
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 1,
        scaleV: 0);
  }

  void shell(double x, double y) {

    final xv = giveOrTake(pi) * 0.5;
    final yv = giveOrTake(pi) * 0.5;
    final rotation = angle(xv, yv) + piHalf;
    _particle(
      type: ParticleType.Shell,
      x: x,
      y: y,
      z: 0.4,
      xv: xv,
      yv: yv,
      zv: 0.05,
      weight: 0.2,
      duration: 100,
      rotation: rotation,
      rotationV: 0,
      scale: 0.25,
    );
  }

  void shotSmoke(double x, double y, double xv, double yv) {
    for (int i = 0; i < 4; i++) {
      double speed = 0.5 + giveOrTake(0.2);
      double cx = clampMagnitudeX(xv, yv, speed) + giveOrTake(0.3);
      double cy = clampMagnitudeY(xv, yv, speed) + giveOrTake(0.3);

      _particle(
          type: ParticleType.Smoke,
          x: x,
          y: y,
          z: 0.3,
          xv: cx,
          yv: cy,
          zv: 0.0075,
          weight: 0.0,
          duration: 120,
          rotation: 0,
          rotationV: 0,
          scale: 0.35 + giveOrTake(0.15),
          scaleV: 0.001 + giveOrTake(0.0005));
    }
  }

  void shrapnel(double x, double y) {
    _particle(
        type: ParticleType.Shrapnel,
        x: x,
        y: y,
        z: 0,
        xv: giveOrTake(2),
        yv: giveOrTake(2),
        zv: randomBetween(0.1, 0.4),
        weight: 0.5,
        duration: randomInt(150, 200),
        scale: randomBetween(0.6, 1.25),
        scaleV: 0);
  }

  void smoke(double x, double y, double z, {double xv = 0, double yv = 0}) {
    _particle(
        type: ParticleType.Smoke,
        x: x,
        y: y,
        z: z,
        xv: xv,
        yv: yv,
        zv: 0.015,
        weight: 0.0,
        duration: 120,
        rotation: 0,
        rotationV: 0,
        scale: 0.2,
        scaleV: 0.005);
  }

  void headZombie(double x, double y, double z, {double xv = 0, double yv = 0}) {
    _particle(
      type: ParticleType.Zombie_Head,
      x: x,
      y: y,
      z: z,
      xv: xv,
      yv: yv,
      zv: 0.06,
      weight: 0.15,
      duration: 200,
      rotation: 0,
      rotationV: 0.05,
      scale: 0.75,
      scaleV: 0,
    );
  }

  void legZombie(double x, double y, double z, {double xv = 0, double yv = 0}) {
    _particle(
        type: ParticleType.Leg,
        x: x,
        y: y,
        z: z,
        xv: xv,
        yv: yv,
        zv: randomBetween(0, 0.03),
        weight: 0.25,
        duration: randomInt(90, 150),
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 0.75,
        scaleV: 0);
  }

  Effect getEffect(){
    for(final effect in game.effects){
      if (!effect.enabled) continue;
      return effect;
    }
    Effect effect = Effect();
    game.effects.add(effect);
    return effect;
  }

  void spawnEffect({
    required double x,
    required double y,
    required EffectType type,
    required int duration,
  }){
    Effect effect = getEffect();
    effect.x = x;
    effect.y = y;
    effect.type = type;
    effect.maxDuration = duration;
    effect.duration = 0;
    effect.enabled = true;
  }

  void explosion(double x, double y) {
    spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
    audio.explosion(x, y);
    modules.game.actions.spawnBulletHole(x, y);
    for (int i = 0; i < randomInt(4, 10); i++) {
      shrapnel(x, y);
    }
    for (int i = 0; i < randomInt(4, 10); i++) {
      fireYellow(x, y);
    }
  }

  void freezeCircle({
    required double x,
    required double y
  }){
    spawnEffect(x: x, y: y, type: EffectType.FreezeCircle, duration: 30);
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