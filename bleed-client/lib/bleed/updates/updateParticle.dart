import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/enums/ParticleType.dart';
import 'package:flutter_game_engine/bleed/spawners/spawnBlood.dart';


void updateParticle(Particle particle){
  double gravity = 0.04;
  double bounceFriction = 0.99;
  double bounceHeightFriction = 0.3;
  double airFriction = 0.98;
  double rotationFriction = 0.93;
  double floorFriction = 0.9;
  bool airBorn = particle.z > 0.01;
  bool falling = particle.zv < 0;

  particle.z += particle.zv;
  particle.x += particle.xv;
  particle.y += particle.yv;
  particle.rotation += particle.rotationV;
  particle.scale += particle.scaleV;

  bool bounce = falling && airBorn && particle.z <= 0;

  if (bounce) {
    particle.zv = -particle.zv * bounceHeightFriction;
    particle.xv = particle.xv * bounceFriction;
    particle.yv = particle.yv * bounceFriction;
    particle.rotationV *= rotationFriction;
  } else if (airBorn) {
    particle.zv -= gravity * particle.weight;
    particle.xv *= airFriction;
    particle.yv *= airFriction;
  } else {
    // on floor
    particle.xv *= floorFriction;
    particle.yv *= floorFriction;
    particle.rotationV *= rotationFriction;
  }
  if (particle.scale < 0) {
    particle.scale = 0;
  }
  if (particle.z <= 0) {
    particle.z = 0;
  }
  if (particle.type == ParticleType.Head && particle.duration & 2 == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.type == ParticleType.Arm && particle.duration & 2 == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.type == ParticleType.Organ && particle.duration & 2 == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
}