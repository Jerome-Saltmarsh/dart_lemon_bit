import 'package:gamestream_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/common/src/particle_type.dart';
import 'package:lemon_math/src.dart';

class ParticleWhisp extends ParticleRoam {

  var movementSpeed = 0.2;
  var movementAngle = 0.0;
  var rotationSpeed = 0.0085;
  var blownByWind = true;

  static const maxScale = 0.4;
  static const minScale = 0.15;
  static const scaleDelta = 0.004;

  ParticleWhisp({
    required super.x,
    required super.y,
    required super.z,
  }) {
    duration = 0;
    durationTotal = -1;
    active = true;
    xv = 0;
    yv = 0;
    zv = 0;
    type = ParticleType.Whisp;
    scale = randomBetween(minScale, maxScale);
    nodeCollidable = false;
    changeTarget();
    scaleVelocity = scaleDelta;
  }




  @override
  void update() {

    updateScale();

    if (blownByWind && wind > 0)
      return;

    updateMovement();
  }

  void updateMovement() {
    if (shouldChangeDestination){
      changeTarget();
    }

    final angle = getAngle(targetX, targetY);
    final diff = radianDiff(angle, movementAngle);

    if (diff < 0){
      movementAngle -= rotationSpeed;
    }  else {
      movementAngle += rotationSpeed;
    }

    setSpeed(movementAngle, movementSpeed);
  }

  void updateScale() {
    if (scale < minScale){

      if (blownByWind && wind > 0) {
        if (y > startY + roamRadius){
          y = startY - roamRadius;
          x = startX + giveOrTake(roamRadius);
          xv *= 0.5;
          yv *= 0.5;
        }
      }


      scaleVelocity = -scaleVelocity;
      scale = minScale;
    } else if (scale > maxScale){
      scaleVelocity = -scaleVelocity;
      scale = maxScale;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void applyAirFriction() {
  }

  @override
  void applyFloorFriction() {

  }
}
