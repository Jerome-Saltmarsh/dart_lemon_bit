import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:lemon_math/library.dart';

import 'vector3.dart';

class Particles {
  static const length = 500;
  final delay = Uint16List(length);
  final xv = Float32List(length);
  final yv = Float32List(length);
  final zv = Float32List(length);
  final frame = Uint16List(length);
  final weight = Float32List(length);
  final duration = Uint16List(length);
  final rotation = Float32List(length);
  final rotationVelocity = Float32List(length);
  final scale = Float32List(length);
  final scaleVelocity = Float32List(length);
  final type = Uint8List(length);
  final bounciness = Float32List(length);
  final checkNodeCollision = List.generate(length, (index) => true);
  final animation = List.generate(length, (index) => false);
  final order = Uint16List(length);

  Particles(){
    for (var i = 0; i < length; i++){
       order[i] = i;
    }
  }

  // void insertionSort() {
  //   final start = 0;
  //   final end = length;
  //   for (var pos = start + 1; pos < end; pos++) {
  //     var min = start;
  //     var max = pos;
  //     var element = order[pos];
  //     while (min < max) {
  //       var mid = min + ((max - min) >> 1);
  //
  //
  //       var comparison = compare(element, list[mid]);
  //       if (comparison < 0) {
  //         max = mid;
  //       } else {
  //         min = mid + 1;
  //       }
  //     }
  //     list.setRange(min + 1, pos + 1, list, min);
  //     list[min] = element;
  //   }
  // }

}

class Particle extends Vector3 {
  var delay = 0;
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;
  var frame = 0;
  var weight = 0.0;
  var duration = 0;
  var rotation = 0.0;
  var rotationVelocity = 0.0;
  var scale = 0.0;
  var scaleV = 0.0;
  var type = 0;
  var bounciness = 0.0;
  // var airFriction = 0.98;
  /// Deactivates if this node hits a solid node
  var checkNodeCollision = true;
  var animation = false;

  bool get active => duration > 0;
  int get direction => Direction.fromRadian(rotation);

  void deactivate(){
    duration = -1;
    frame = 0;
  }

  void setAngle({required double value, required double speed}){
    xv = getAdjacent(value, speed);
    yv = getOpposite(value, speed);
  }

  void updateMotion(){
    x += xv;
    y += yv;
    z += zv;
    if (z < 0){
      z = 0;
    }
    if (rotationVelocity != 0){
      rotation = clampAngle(rotation + rotationVelocity);
    }
    if (scaleV != 0){
      scale += scaleV;
      if (scale < 0){
        scale = 0;
      }
    }
  }

  void applyAirFriction(){
    const gravity = 0.04;
    const airFriction = 0.98;
    zv -= gravity * weight;
    xv *= airFriction;
    yv *= airFriction;
  }

  void applyFloorFriction(){
    const floorFriction = 0.9;
    const rotationFriction = 0.93;
    xv *= floorFriction;
    yv *= floorFriction;
    rotationVelocity *= rotationFriction;
  }

  void applyLimits(){
    if (scale < 0) {
      scale = 0;
    }
    if (z <= 0) {
      z = 0;
    }
  }
}

