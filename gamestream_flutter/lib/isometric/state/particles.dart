
import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';

final particles = <Particle>[];


void sortParticles(){
  insertionSort(
    particles,
    compare: _compareParticles,
  );
}

int _compareParticles(Particle a, Particle b) {
  if (!a.active) {
    if (!b.active){
      return 0;
    }
    return 1;
  }
  if (!b.active) {
    return -1;
  }
  return a.y > b.y ? 1 : -1;
}

Particle? next;

Particle getParticleInstance() {
  final value = next;
  if (value != null) {
    next = value.next;
    value.next = null;
    return value;
  }

  for (final particle in particles) {
    if (particle.active) continue;
    return particle;
  }

  final instance = Particle();
  particles.add(instance);
  return instance;
}



void updateParticles() {

  for (final particle in particles) {
    if (!particle.active) continue;
    _updateParticle(particle);
  }

  if (engine.frame % 6 != 0) return;
  for (final particle in particles) {
    if (!particle.active) continue;
    if (!particle.bleeds) continue;
    if (particle.speed < 2.0) continue;
    isometric.spawn.spawnParticleBlood(
        x: particle.x,
        y: particle.y,
        z: particle.z,
        zv: 0,
        angle: 0,
        speed: 0,
    );
  }
}

void _updateParticle(Particle particle){
  final airBorn = particle.z > 0.01;
  final bounce = particle.zv < 0 && !airBorn;
  particle.updateMotion();

  if (bounce) {
    if (particle.type == GridNodeType.Bricks){
      _deactivateParticle(particle);
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
    // if (!tileIsWalkable(particle)){
    //   _deactivateParticle(particle);
    //   return;
    // }
  }
  particle.applyLimits();
  if (particle.duration-- <= 0) {
    _deactivateParticle(particle);
  }
}

void _deactivateParticle(Particle particle) {
  particle.duration = -1;
  if (next != null) {
    next = particle;
    particle.next = next;
    return;
  }
  next = particle;
}