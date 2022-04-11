
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'module.dart';

final _particles = isometric.particles;
final _spawn = isometric.spawn;

class IsometricUpdate {

  final IsometricModule state;
  final IsometricSpawn spawn;

  IsometricUpdate(this.state, this.spawn);

  void call(){
    _updateParticles();
    _updateParticleEmitters();
  }


  void _updateParticles() {

    for (final particle in _particles) {
      if (!particle.active) continue;
      updateParticle(particle);
    }

    if (engine.frame % 6 == 0) {
      for (final particle in _particles) {
        if (!particle.active) continue;
        if (!particle.bleeds) continue;
        if (particle.speed < 2.0) continue;
        spawn.blood(x: particle.x, y: particle.y, z: particle.z, zv: 0, angle: 0, speed: 0);
      }
    }
  }

  void updateParticle(Particle particle){
    final airBorn = particle.z > 0.01;
    final bounce = particle.zv < 0 && !airBorn;
    particle.updateMotion();

    if (bounce) {
      if (!state.tileIsWalkable(particle)){
        deactivateParticle(particle);
        return;
      }
      if (particle.zv < -0.1){
        particle.zv = -particle.zv * particle.bounciness;
      } else {
        particle.zv = 0;
      }

    } else if (airBorn) {
      particle.applyAirFriction();
    } else {
      particle.applyFloorFriction();
      if (!state.tileIsWalkable(particle)){
        deactivateParticle(particle);
        return;
      }
    }
    particle.applyLimits();
    if (particle.duration-- <= 0) {
      deactivateParticle(particle);
    }
  }

  void deactivateParticle(Particle particle) {
    particle.duration = -1;
    final next = state.next;
    if (next != null) {
      state.next = particle;
      particle.next = next;
      return;
    }
    state.next = particle;
  }

  void _updateParticleEmitters() {
    for (final emitter in state.particleEmitters) {
      if (emitter.next-- > 0) continue;
      emitter.next = emitter.rate;
      final particle = _spawn.getAvailableParticle();
      particle.x = emitter.x;
      particle.y = emitter.y;
      emitter.emit(particle);
    }
  }
}