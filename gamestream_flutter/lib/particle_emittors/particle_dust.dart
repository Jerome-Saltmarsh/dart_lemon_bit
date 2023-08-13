
import 'package:gamestream_flutter/gamestream/isometric/classes/src.dart';
import 'package:gamestream_flutter/library.dart';

class ParticleDust extends Particle {

  var startX = 0.0;
  var startY = 0.0;
  var startZ = 0.0;

  var destinationX = 0.0;
  var destinationY = 0.0;
  var destinationZ = 0.0;
  var roamRadius = 150.0;
  var movementSpeed = 0.2;
  var movementAngle = 0.0;
  var rotationSpeed = 0.0085;

  static const maxScale = 0.4;
  static const minScale = 0.15;
  static const scaleDelta = 0.004;

  ParticleDust({
    required super.x,
    required super.y,
    required super.z,
  }) {
    startX = x;
    startY = y;
    startZ = z;
    duration = 1;
    durationTotal = 2;
    active = true;
    xv = 0;
    yv = 0;
    zv = 0;
    type = ParticleType.Dust;
    scale = randomBetween(minScale, maxScale);
    nodeCollidable = false;
    changeDestination();
    scaleVelocity = scaleDelta;
  }

  bool get shouldChangeDestination => withinRadius(
      x: destinationX,
      y: destinationY,
      z: destinationZ,
      radius: 5,
  );



  @override
  void update() {
    if (shouldChangeDestination){
      changeDestination();
    }

    final angle = getAngle(destinationX, destinationY);
    final diff = radianDiff(angle, movementAngle);

    if (diff < 0){
      movementAngle -= rotationSpeed;
    }  else {
      movementAngle += rotationSpeed;
    }
    if (scale < minScale){
      scaleVelocity = -scaleVelocity;
      scale = minScale;
    } else if (scale > maxScale){
      scaleVelocity = -scaleVelocity;
      scale = maxScale;
    }
    setSpeed(movementAngle, movementSpeed);
  }

  void changeDestination(){
    destinationX = startX + giveOrTake(roamRadius);
    destinationY = startY + giveOrTake(roamRadius);
    destinationZ = startZ;
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
