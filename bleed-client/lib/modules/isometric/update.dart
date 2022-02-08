
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/functions.dart';
import 'package:bleed_client/functions/spawners/spawnBlood.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/queries.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';

class IsometricUpdate {

  final IsometricState state;
  final IsometricQueries queries;
  IsometricUpdate(this.state, this.queries);

  void deadZombieBlood() {
    if (core.state.timeline.frame % 2 == 0) return;

    for (int i = 0; i < game.totalZombies.value; i++) {
      if (game.zombies[i].alive) continue;
      spawnBlood(game.zombies[i].x, game.zombies[i].y, 0);
    }
  }

  void updateParticles() {
    for (Particle particle in isometric.state.particles) {
      if (!particle.active) continue;
      updateParticle(particle);
    }
    insertionSort(
        isometric.state.particles,
        compare: compareParticles,
        start: 0,
        end: isometric.state.particles.length);
  }


  void updateParticle(Particle particle){
    final _spawnBloodRate = 8;
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

      if (!queries.tileIsWalkable(particle.x, particle.y)){
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

      if (!queries.tileIsWalkable(particle.x, particle.y)){
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

  void updateParticleEmitters() {
    for (ParticleEmitter emitter in state.particleEmitters) {
      if (emitter.next-- > 0) continue;
      emitter.next = emitter.rate;
      final particle = isometric.instances.getAvailableParticle();
      particle.active = true;
      particle.x = emitter.x;
      particle.y = emitter.y;
      emitter.emit(particle);
    }
  }
}