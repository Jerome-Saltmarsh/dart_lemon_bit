import 'dart:typed_data';

import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/classes/item.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/state/particle_emitters.dart';
import 'package:gamestream_flutter/modules/game/emit_particle.dart';
import 'package:lemon_watch/watch.dart';

class IsometricModule {
  final paths = Float32List(10000);
  final targets = Float32List(10000);
  final items = <Item>[];
  final maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  var targetsTotal = 0;
  var totalStructures = 0;

  // CONSTRUCTOR

  IsometricModule(){
    for(var i = 0; i < 300; i++){
      items.add(Item(type: ItemType.Armour_Plated, x: 0, y: 0));
    }
  }

  // METHODS


  bool tileIsWalkable(Vector3 position){
    final tile = position.tile;
    return tile == GridNodeType.Bricks;
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

  void addSmokeEmitter(double x, double y){
    particleEmitters.add(ParticleEmitter(x: x, y: y, rate: 12, emit: emitSmoke));
  }
}
