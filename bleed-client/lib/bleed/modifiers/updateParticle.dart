

import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/enums/ParticleType.dart';
import 'package:flutter_game_engine/bleed/spawners/spawnBlood.dart';

import '../state.dart';

void updateParticles() {
  for (int i = 0; i < particles.length; i++) {
    Particle particle = particles[i];
    if (particle.duration-- < 0) {
      particles.removeAt(i);
      i--;
      continue;
    }

    double gravity = 0.04;
    double bounceFriction = 0.99;
    double bounceHeightFriction = 0.3;
    double airFriction = 0.98;
    double rotationFriction = 0.93;
    double floorFriction = 0.9;

    bool airBorn = particle.z > 0.01;
    particle.z = particle.z + particle.zv;
    if(particle.z <= 0.0001){
      particle.z = 0;
    }
    bool bounce = airBorn && particle.z <= 0;

    if (bounce) {
      particle..zv = -particle.zv * bounceHeightFriction;
      particle.xv = particle.xv * bounceFriction;
      particle.yv = particle.yv * bounceFriction;
      particle.rotationV *= rotationFriction;
    }else if(airBorn){
      particle..zv -= gravity;
      particle.xv *= airFriction;
      particle.yv *= airFriction;
    }else{ // on floor
      particle.xv *= floorFriction;
      particle.yv *= floorFriction;
      particle.rotationV *= rotationFriction;
    }
    particle.x += particle.xv;
    particle.y += particle.yv;
    particle.rotation += particle.rotationV;

    if (particle.type == ParticleType.Head &&
        particle.duration & 2 == 0) {
        spawnBlood(particle.x, particle.y, particle.z);
    }

    if (particle.type == ParticleType.Arm &&
        particle.duration & 2 == 0) {
      spawnBlood(particle.x, particle.y, particle.z);
    }
    if (particle.type == ParticleType.Organ &&
        particle.duration & 2 == 0) {
      spawnBlood(particle.x, particle.y, particle.z);
    }
  }
}