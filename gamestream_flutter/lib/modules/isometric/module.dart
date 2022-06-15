import 'dart:typed_data';

import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/classes/floating_text.dart';
import 'package:gamestream_flutter/isometric/classes/item.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/structure.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/state/grid.dart';
import 'package:gamestream_flutter/isometric/state/particle_emitters.dart';
import 'package:gamestream_flutter/isometric/state/particles.dart';
import 'package:gamestream_flutter/isometric/state/time.dart';
import 'package:gamestream_flutter/modules/game/emit_particle.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'render.dart';


class IsometricModule {
  late final IsometricRender render;
  late final IsometricSpawn spawn;
  final paths = Float32List(10000);
  final targets = Float32List(10000);
  final structures = <Structure>[];
  final gemSpawns = <GemSpawn>[];
  final floatingTexts = <FloatingText>[];
  // final dynamic = <Int8List>[];
  // final bake = <Int8List>[];
  final items = <Item>[];
  // final totalColumns = Watch(0);
  // final totalRows = Watch(0);
  final maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  var targetsTotal = 0;
  var totalRowsInt = 0;
  var totalStructures = 0;
  var minRow = 0;
  var maxRow = 0;
  var minColumn = 0;
  var maxColumn = 0;

  Particle? next;

  // PROPERTIES

  bool get dayTime => ambient.value == Shade.Bright;


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
    render = IsometricRender(this);

    for(var i = 0; i < 300; i++){
      particles.add(Particle());
      items.add(Item(type: ItemType.Armour_Plated, x: 0, y: 0));
    }
    for (var i = 0; i < 1000; i++) {
      structures.add(Structure());
    }
  }

  // METHODS

  void sortParticles(){
    insertionSort(
      particles,
      compare: compareParticles,
    );
  }

  int compareParticles(Particle a, Particle b) {
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

  void detractHour(){
    print("isometric.actions.detractHour()");
    hours.value = (hours.value - 1) % 24;
  }

  void addHour(){
    hours.value = (hours.value + 1) % 24;
  }

  void setHour(int hour) {
    hours.value = hour * secondsPerHour;
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
      final particle = spawn.getAvailableParticle();
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

  void spawnFloatingText(double x, double y, String text) {
    final floatingText = _getFloatingText();
    floatingText.duration = 50;
    floatingText.x = x;
    floatingText.y = y;
    floatingText.xv = giveOrTake(0.2);
    floatingText.value = text;
  }

  FloatingText _getFloatingText(){
    for (final floatingText in floatingTexts) {
      if (floatingText.duration > 0) continue;
      return floatingText;
    }
    final instance = FloatingText();
    floatingTexts.add(instance);
    return instance;
  }

  void addSmokeEmitter(double x, double y){
    particleEmitters.add(ParticleEmitter(x: x, y: y, rate: 12, emit: emitSmoke));
  }
}


// double convertWorldToGridX(double x, double y){
//   return (x + y) ~/ 48.0;
//   return getTile((x + y) ~/ 48.0, (y - x) ~/ 48.0);
// }