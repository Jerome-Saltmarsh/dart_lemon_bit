

import 'package:amulet_client/isometric/classes/particle.dart';
import 'package:lemon_math/src.dart';

abstract class ParticleRoam extends Particle {
  var startX = 0.0;
  var startY = 0.0;
  var startZ = 0.0;
  var targetX = 0.0;
  var targetY = 0.0;
  var targetZ = 0.0;
  var roamRadius = 150.0;

  ParticleRoam({required super.x, required super.y, required super.z}){
    startX = x;
    startY = y;
    startZ = z;
    changeTarget();
  }

  bool get closeToTarget => withinRadius(
    x: targetX,
    y: targetY,
    z: targetZ,
    radius: 3,
  );

  void changeTarget(){
    targetX = startX + giveOrTake(roamRadius);
    targetY = startY + giveOrTake(roamRadius);
    targetZ = z;
  }
}