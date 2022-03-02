
import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/functions.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/queries.dart';
import 'package:bleed_client/modules/isometric/spawn.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

const pi2 = pi + pi;

class IsometricUpdate {

  final IsometricState state;
  final IsometricQueries queries;
  final IsometricSpawn spawn;
  IsometricUpdate(this.state, this.queries, this.spawn);

  void call(){
    updateVisibleTiles();
    _updateParticles();
    _updateParticleEmitters();
  }

  void updateVisibleTiles() {
    final screen = engine.screen;
    state.minRow = max(0, getRow(screen.left, screen.top));
    state.maxRow = min(state.totalRowsInt, getRow(screen.right, screen.bottom));
    state.minColumn = max(0, getColumn(screen.right, screen.top));
    state.maxColumn = min(state.totalColumnsInt, getColumn(screen.left, screen.bottom));
  }

  void _updateParticles() {
    final particles = isometric.state.particles;
    for (final particle in particles) {
      if (!particle.active) continue;
      updateParticle(particle);
    }
    insertionSort(
        particles,
        compare: compareParticles,
        start: 0,
        end: particles.length);

    if (engine.frame % 4 == 0) {
      for (final particle in particles) {
        if (!particle.active) continue;
        if (particle.type != ParticleType.Zombie_Head) continue;
        if (particle.xv + particle.yv < 0.005) continue;
        spawn.blood(x: particle.x, y: particle.y, z: particle.z, zv: 0, angle: 0, speed: 0);
      }
    }
  }

  void updateParticle(Particle particle){
    final gravity = 0.04;
    final bounceFriction = 0.99;
    final rotationFriction = 0.93;
    final floorFriction = 0.9;
    final airBorn = particle.z > 0.01;
    final falling = particle.zv < 0;
    final bounce = falling && airBorn && particle.z <= 0;
    particle.z += particle.zv;
    particle.x += particle.xv;
    particle.y += particle.yv;
    if (particle.rotationV != 0){
      particle.rotation = (particle.rotation + particle.rotationV) % pi2;
    }
    particle.scale += particle.scaleV;

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
    if (particle.duration-- < 0) {
      particle.active = false;
      final next = state.next;
      if (next != null){
        state.next = particle;
        particle.next = next;
      }else {
        state.next = particle;
      }
    }
  }

  void _updateParticleEmitters() {
    for (final emitter in state.particleEmitters) {
      if (emitter.next-- > 0) continue;
      emitter.next = emitter.rate;
      final particle = isometric.spawn.getAvailableParticle();
      particle.active = true;
      particle.x = emitter.x;
      particle.y = emitter.y;
      emitter.emit(particle);
    }
  }
}