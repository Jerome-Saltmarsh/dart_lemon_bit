
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/spawners/spawnBlood.dart';
import 'package:bleed_client/state/getters/isWalkable.dart';
import 'package:bleed_client/state/isWaterAt.dart';

void updateParticle(Particle particle){
  double gravity = 0.04;
  double bounceFriction = 0.99;
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

    if (!isWalkable(particle.x, particle.y)){
      particle.active = false;
      return;
    }

    particle.zv = -particle.zv * particle.bounciness;
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

    if (!isWalkable(particle.x, particle.y)){
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
  if (particle.type == ParticleType.Head && particle.duration & 2 == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.type == ParticleType.Arm && particle.duration & 2 == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.type == ParticleType.Organ && particle.duration & 2 == 0) {
    spawnBlood(particle.x, particle.y, particle.z);
  }
  if (particle.duration-- < 0) {
    particle.active = false;
  }
}