

import 'package:gamestream_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_particles.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_math/src.dart';

class ButterflyMode {
  static const flying = 0;
  static const landing = 1;
  static const landed = 2;
  static const takingOff = 3;
}

/// flying
/// landing
/// landed
/// taking-off
class ParticleButterfly extends ParticleRoam {

  var speed = 1.5;
  var moving = false;
  var duration = 0;
  var mode = ButterflyMode.flying;

  static const changeTargetRadius = 5.0;
  static const verticalSpeed = 1.5;

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

    if (type == ParticleType.Bat){
      updateBat();
    } else {
      updateButterfly(particles);
    }
  }

  void updateButterfly(IsometricParticles particles) {

    switch (mode) {
      case ButterflyMode.flying:
        if (duration-- <= 0){
          mode = ButterflyMode.landing;
          vx = 0;
          vy = 0;
          targetZ = particles.scene.getProjectionZ(this) + 0.1;
        } else if (shouldChangeDestination){
          changeTarget();
        }
        break;
      case ButterflyMode.landing:
        if (z > targetZ){
          z -= verticalSpeed;
        } else {
          mode = ButterflyMode.landed;
          duration = randomInt(300, 500);
          moving = false;
          vx = 0;
          vy = 0;
          vz = 0;
        }
        break;
      case ButterflyMode.landed:
        if (duration-- <= 0){
          takeOff();
        } else {
          final scene = particles.scene;
          final characters = scene.characters;
          final totalCharacters = scene.totalCharacters;
          for (var i = 0; i < totalCharacters; i++){
            final character = characters[i];
            if (this.withinRadiusPosition(position: character, radius: 24)){
              takeOff();
            }
          }
        }
        break;
      case ButterflyMode.takingOff:
        if (z < targetZ){
          z += verticalSpeed;
        } else {
          mode = ButterflyMode.flying;
          duration = randomInt(300, 500);
          changeTarget();
        }
    }

    if (moving && particles.screen.contains(this)){
      particles.render.projectShadow(this);
    }
  }

  void takeOff() {
    mode = ButterflyMode.takingOff;
    targetZ = z + Node_Height + Node_Height_Half;
    moving = true;
  }

  void updateBat(){

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