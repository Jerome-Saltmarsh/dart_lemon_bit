
import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/maths.dart';
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

  void spawnParticle({
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

    Particle particle = getAvailableParticle();
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

  void spawnArm(double x, double y, double z, {double xv = 0, double yv = 0}) {
    spawnParticle(
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

  void spawnBlood(double x, double y, double z,
      {double xv = 0, double yv = 0, double zv = 0}) {
    spawnParticle(
        type: ParticleType.Blood,
        x: x,
        y: y,
        z: z,
        xv: xv,
        yv: yv,
        zv: zv,
        weight: 0.1,
        duration: randomInt(90, 170),
        rotation: 0,
        rotationV: 0,
        scale: 0.4,
        scaleV: 0,
        bounciness: 0);
  }

  void spawnFireYellow(double x, double y){
    spawnParticle(
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

  void spawnHead(double x, double y, double z, {double xv = 0, double yv = 0}) {
    spawnParticle(
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

  void spawnOrgan(double x, double y, double z, {double xv = 0, double yv = 0}) {
    spawnParticle(
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

  void spawnShell(double x, double y) {

    double xv = giveOrTake(pi) * 0.5;
    double yv = giveOrTake(pi) * 0.5;
    double rotation = angle(xv, yv) + piHalf;
    spawnParticle(
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

  void spawnShotSmoke(double x, double y, double xv, double yv) {
    for (int i = 0; i < 4; i++) {
      double speed = 0.5 + giveOrTake(0.2);
      double cx = clampMagnitudeX(xv, yv, speed) + giveOrTake(0.3);
      double cy = clampMagnitudeY(xv, yv, speed) + giveOrTake(0.3);

      spawnParticle(
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

  void spawnShrapnel(double x, double y) {
    spawnParticle(
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
  void spawnSmoke(double x, double y, double z, {double xv = 0, double yv = 0}) {
    spawnParticle(
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

  void spawnZombieHead(double x, double y, double z, {double xv = 0, double yv = 0}) {
    spawnParticle(
      type: ParticleType.Zombie_Head,
      x: x,
      y: y,
      z: z,
      xv: xv,
      yv: yv,
      zv: randomBetween(0.04, 0.08),
      weight: 0.15,
      duration: randomInt(90, 150),
      rotation: giveOrTake(pi),
      rotationV: 0.05,
      scale: 0.75,
      scaleV: 0,
    );
  }

  void spawnZombieLeg(double x, double y, double z, {double xv = 0, double yv = 0}) {
    spawnParticle(
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
}