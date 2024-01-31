import 'package:amulet_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_particles.dart';
import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_engine/packages/lemon_math.dart';

class ParticleWhisp extends ParticleRoam {

  var movementSpeed = 0.4;
  var movementAngle = 0.0;
  var rotationSpeed = 0.0085;
  var targetDuration = 0;

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
    vx = 0;
    vy = 0;
    vz = 0;
    type = ParticleType.Whisp;
    scale = randomBetween(minScale, maxScale);
    nodeCollidable = false;
    changeTarget();
    scaleVelocity = scaleDelta;
  }

  @override
  void update(IsometricParticles particles) {

    updateScale();

    if (blownByWind && wind > 0)
      return;

    updateMovement();
  }

  @override
  bool get closeToTarget =>
      super.closeToTarget || targetDuration > 400;

  @override
  void changeTarget() {
    super.changeTarget();
    targetDuration = 0;
  }

  void updateMovement() {
    if (closeToTarget){
      changeTarget();
    }

    targetDuration++;

    final angle = getAngle(targetX, targetY);
    final diff = angleDiff(angle, movementAngle);

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
          vx *= 0.5;
          vy *= 0.5;
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
