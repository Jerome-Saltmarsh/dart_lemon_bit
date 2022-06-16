import 'dart:typed_data';

import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/classes/item.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/state/particle_emitters.dart';
import 'package:gamestream_flutter/isometric/state/particles.dart';
import 'package:gamestream_flutter/modules/game/emit_particle.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

class IsometricModule {
  late final IsometricSpawn spawn;
  final paths = Float32List(10000);
  final targets = Float32List(10000);
  final items = <Item>[];
  final maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  var targetsTotal = 0;
  var totalStructures = 0;

  int get totalActiveParticles {
    var totalParticles = 0;
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      if (!particles[i].active) continue;
      totalParticles++;
    }
    return totalParticles;
  }

  // CONSTRUCTOR

  IsometricModule(){
    spawn = IsometricSpawn(this);

    for(var i = 0; i < 300; i++){
      particles.add(Particle());
      items.add(Item(type: ItemType.Armour_Plated, x: 0, y: 0));
    }
  }

  // METHODS


  bool tileIsWalkable(Vector3 position){
    final tile = position.tile;
    return tile == GridNodeType.Bricks;
  }

  void applyShade(List<List<int>> shader, int row, int column, int value) {
    applyShadeAtRow(shader[row], column, value);
  }

  void applyShadeAtRow(List<int> shadeRow, int column, int value) {
    if (shadeRow[column] <= value) return;
    shadeRow[column] = value;
  }

  void emitLightLow(List<List<int>> shader, double x, double y) {
    final column = convertWorldToColumn(x, y);
    if (column < 0) return;
    if (column >= shader[0].length) return;
    final row = convertWorldToRow(x, y);
    if (row < 0) return;
    if (row >= shader.length) return;

    applyShade(shader, row, column, Shade.Medium);
  }

  void cameraCenterMap(){
    // final center = mapCenter;
    // engine.cameraCenter(center.x, center.y);
  }

  void applyEmissionFromEffects() {
    for (final effect in game.effects) {
      if (!effect.enabled) continue;
      final percentage = effect.percentage;
      if (percentage < 0.33) {
        break;
      }
      if (percentage < 0.66) {
        break;
      }
    }
  }

  void updateParticles() {

    for (final emitter in particleEmitters) {
      if (emitter.next-- > 0) continue;
      emitter.next = emitter.rate;
      final particle = getParticleInstance();
      particle.x = emitter.x;
      particle.y = emitter.y;
      emitter.emit(particle);
    }

    for (final particle in particles) {
      if (!particle.active) continue;
      _updateParticle(particle);
    }

    if (engine.frame % 6 == 0) {
      for (final particle in particles) {
        if (!particle.active) continue;
        if (!particle.bleeds) continue;
        if (particle.speed < 2.0) continue;
        spawn.spawnParticleBlood(x: particle.x, y: particle.y, z: particle.z, zv: 0, angle: 0, speed: 0);
      }
    }
  }

  void _updateParticle(Particle particle){
    final airBorn = particle.z > 0.01;
    final bounce = particle.zv < 0 && !airBorn;
    particle.updateMotion();

    if (bounce) {
      if (!tileIsWalkable(particle)){
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
      if (!tileIsWalkable(particle)){
        _deactivateParticle(particle);
        return;
      }
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

  void addSmokeEmitter(double x, double y){
    particleEmitters.add(ParticleEmitter(x: x, y: y, rate: 12, emit: emitSmoke));
  }
}
