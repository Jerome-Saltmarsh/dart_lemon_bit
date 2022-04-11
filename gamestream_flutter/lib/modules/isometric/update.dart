
import 'dart:math';

import 'package:bleed_common/Tile.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/modules/isometric/queries.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:gamestream_flutter/modules/isometric/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

final _particles = isometric.state.particles;
final _spawn = isometric.spawn;
final _screen = engine.screen;

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
    state.minRow = max(0, getRow(_screen.left, _screen.top));
    state.maxRow = min(state.totalRowsInt, getRow(_screen.right, _screen.bottom));
    state.minColumn = max(0, getColumn(_screen.right, _screen.top));
    state.maxColumn = min(state.totalColumnsInt, getColumn(_screen.left, _screen.bottom));
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