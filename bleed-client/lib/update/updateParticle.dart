
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/spawners/spawnBlood.dart';
import 'package:bleed_client/getters/isWalkable.dart';

const _spawnBloodRate = 8;

void updateParticle(Particle particle){
  double gravity = 0.04;
  double bounceFriction = 0.99;
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

    if (!tileIsWalkable(particle.x, particle.y)){
      particle.active = false;
      return;
    }

    particle.zv = -particle.zv * particle.bounciness;
    particle.xv = particle.xv * bounceFriction;
    particle.yv = particle.yv * bounceFriction;
    particle.rotationV *= rotationFriction;
  } else if (airBorn) {
    particle.zv -= gravity * particle.weight;
    particle.xv *= particle.airFriction;
    particle.yv *= particle.airFriction;
  } else {
    // on floor
    particle.xv *= floorFriction;
    particle.yv *= floorFriction;
    particle.rotationV *= rotationFriction;

    if (!tileIsWalkable(particle.x, particle.y)){
      particle.active = false;
      return;
    }
  }
  if (particle.scale < 0) {
    particle.scale = 0;
  }
  if (particle.z <= 0) {
    particle.z = 0;
  }
  if (particle.type == ParticleType.Human_Head && particle.duration % _spawnBloodRate == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.type == ParticleType.Arm && particle.duration % _spawnBloodRate == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.type == ParticleType.Organ && particle.duration % _spawnBloodRate == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.duration-- < 0) {
    particle.active = false;
  }
}