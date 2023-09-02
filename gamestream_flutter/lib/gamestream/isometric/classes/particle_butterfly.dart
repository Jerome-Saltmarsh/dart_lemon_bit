

import 'package:gamestream_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:gamestream_flutter/packages/common/src/particle_type.dart';

class ParticleButterfly extends ParticleRoam {

  var speed = 0.25;

  static const changeTargetRadius = 5.0;

  ParticleButterfly({required super.x, required super.y, required super.z}) {
    type = ParticleType.Butterfly;
    startX = x;
    startY = y;
    startZ = z;
    durationTotal = -1;
    nodeCollidable = false;
    active = true;
    changeTarget();
  }

  @override
  void update() {
    if (shouldChangeDestination){
      changeTarget();
    }
    // x += xv;
    // y += yv;
    // z += zv;
  }

  @override
  void applyAirFriction() {

  }

  @override
  void changeTarget(){
    super.changeTarget();
    rotation = getAngle(targetX, targetY);
    setSpeed(rotation, speed);
  }
}