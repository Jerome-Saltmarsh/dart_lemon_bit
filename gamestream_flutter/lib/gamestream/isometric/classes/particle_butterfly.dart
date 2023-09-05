

import 'package:gamestream_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_particles.dart';
import 'package:gamestream_flutter/packages/common/src/particle_type.dart';
import 'package:lemon_math/src.dart';

class ParticleButterfly extends ParticleRoam {

  var speed = 1.0;
  var moving = false;
  var duration = 0;

  static const changeTargetRadius = 5.0;

  ParticleButterfly({required super.x, required super.y, required super.z}) {
    type = ParticleType.Butterfly;
    startX = x;
    startY = y;
    startZ = z;
    durationTotal = -1;
    nodeCollidable = false;
    active = true;
    duration = randomInt(0, 500);


  }

  @override
  void update(IsometricParticles particles) {
    if (duration-- <= 0){
      duration = randomInt(300, 500);
      toggleMoving();
    }

    if (moving && shouldChangeDestination){
      changeTarget();
    }

    particles.render.projectShadow(this);
  }

  void toggleMoving() {
    moving = !moving;

    if (moving){
      changeTarget();
    } else {
      vx = 0;
      vy = 0;
      vz = 0;
    }
  }

  @override
  void applyAirFriction() {

  }

  @override
  void changeTarget(){
    super.changeTarget();
    rotation = getAngle(targetX, targetY);
    setSpeed(rotation, speed);
    moving = true;
  }
}