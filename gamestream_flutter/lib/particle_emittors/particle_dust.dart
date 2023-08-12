
import 'package:gamestream_flutter/gamestream/isometric/classes/src.dart';
import 'package:gamestream_flutter/library.dart';

class ParticleDust extends Particle {

  var startX = 0.0;
  var startY = 0.0;
  var startZ = 0.0;

  var destinationX = 0.0;
  var destinationY = 0.0;
  var destinationZ = 0.0;
  var roamRadius = 250.0;
  var movementSpeed = 0.2;
  var movementAngle = 0.0;
  var rotationSpeed = 0.01;

  ParticleDust({
    required super.x,
    required super.y,
    required super.z,
  }) {
    print('ParticleDust()');
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
    scale = 0.25;
    nodeCollidable = false;
    changeDestination();
  }

  bool get shouldChangeDestination => withinRadius(x: destinationX, y: destinationY, z: destinationZ, radius: roamRadius);

  @override
  void update() {
    if (shouldChangeDestination){
      changeDestination();
    }

    final angle = getAngle(destinationX, destinationY);
    final diff = angleDiff(angle, movementAngle);

    if (diff > 0){
      movementAngle -= rotationSpeed;
    }  else {
      movementAngle += rotationSpeed;
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
