

import 'dart:typed_data';

import 'package:gamestream_flutter/bool_list.dart';

class GameParticles {
  static const total = 1000;
  static final masses = Float32List(total);
  static final positionsX = Float32List(total);
  static final positionsY = Float32List(total);
  static final positionsZ = Float32List(total);
  static final velocitiesX = Float32List(total);
  static final velocitiesY = Float32List(total);
  static final velocitiesZ = Float32List(total);
  static final accelerationsX = Float32List(total);
  static final accelerationsY = Float32List(total);
  static final accelerationsZ = Float32List(total);
  static final types = Uint8List(total);
  static final actives = BoolList(total);
  static final durations = Int16List(total);
  static final maxDurations = Int16List(total);
  static final order = Int16List(total);
  static final _inactive = Int16List(total);

  static void spawn({
    required double positionX,
    required double positionY,
    required double positionZ,
    required double velocityX,
    required double velocityY,
    required double velocityZ,
    /// Assign 0 to last forever
    int maxDuration = 30,
    double mass = 1.0,
  }) {
    final i = 0; // calculate next available index
    actives[i] = true;
    positionsX[i] = positionX;
    positionsY[i] = positionY;
    positionsZ[i] = positionZ;
    velocitiesX[i] = velocityX;
    velocitiesY[i] = velocityY;
    velocitiesZ[i] = velocityZ;
    durations[i] = 0;
    maxDurations[i] = maxDuration;
    masses[i] = mass;
  }

  /// remember objects and garbage collection are far more expensive than array lookups
  /// the goal is to remove objects
  ///
  /// if max duration is 0 then the particle lasts forever
  static void update(){
      for (var i = 0; i < total; i++) {
        if (!actives[i]) continue;
        if (maxDurations[i] > 0 && maxDurations[i] <= durations[i]++) {
          actives[i] = false;
          continue;
        }
        const gravity = 9.8 / 60;
        accelerationsY[i] += gravity * masses[i];
        velocitiesX[i] += accelerationsX[i];
        velocitiesY[i] += accelerationsY[i];
        velocitiesZ[i] += accelerationsZ[i];
        accelerationsX[i] = 0;
        accelerationsY[i] = 0;
        accelerationsZ[i] = 0;

        // before assigning this do a collision check on the target
        positionsX[i] += velocitiesX[i];
        positionsY[i] += velocitiesY[i];
        positionsZ[i] += velocitiesZ[i];

        // if a collision occurs
          // ask the engine how to resolve it

      }
  }
}