
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:lemon_math/library.dart';

import 'particles.dart';

final particleEmitters = <ParticleEmitter>[];

void updateParticleEmitters(){
  for (final emitter in particleEmitters) {
    if (emitter.next-- > 0) continue;
    emitter.next = emitter.rate;
    final particle = getParticleInstance();
    particle.x = emitter.x;
    particle.y = emitter.y;
    particle.z = emitter.z;
    emitter.emit(particle);
  }

  if (animationFrame % 30 == 0){
    for (var i = 0; i < totalGameObjects; i++){
      if (gameObjects[i].type != GameObjectType.Crystal) continue;
      final crystal = gameObjects[i];
      spawnParticleOrbShard(
        x: crystal.x,
        y: crystal.y,
        z: crystal.z,
        speed: 1.5,
        duration: 24,
      );
    }
  }
}

void isometricParticleEmittersActionAddSmokeEmitter(double x, double y){
  // particleEmitters.add(ParticleEmitter(x: x, y: y, rate: 12, emit: emitSmoke));
}

void addSmokeEmitter(int z, int row, int column){
  particleEmitters.add(
      ParticleEmitter(
          z: z,
          row: row,
          column: column,
          rate: 12,
          emit: emitSmoke,
      )
  );
}

void emitSmoke(Particle particle) {
  particle.type = ParticleType.Smoke;
  particle.duration = randomBetween(150, 200).toInt();
  particle.weight = 0;
  particle.scale = 0.15;
  particle.scaleV = 0.002;
  particle.rotation = 0;
  particle.rotationVelocity = 0;
  particle.bounciness = 0;
  particle.xv = randomBetween(0, -pi * 0.1);
  particle.yv = randomBetween(0, pi * 0.1);
  particle.zv = 0.25;
  particle.airFriction = 0.99;
}
