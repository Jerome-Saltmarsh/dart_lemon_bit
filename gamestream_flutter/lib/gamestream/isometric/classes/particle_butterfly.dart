

import 'package:gamestream_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
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
  var roamDuration = 0;
  var mode = ButterflyMode.flying;

  static const changeTargetRadius = 5.0;
  static const verticalSpeed = 1.5;
  static const verticalSpeedBat = 0.3;
  static const speedBat = 1.5;

  ParticleButterfly({required super.x, required super.y, required super.z}) {
    type = ParticleType.Butterfly;
    startX = x;
    startY = y;
    startZ = z;
    durationTotal = -1;
    nodeCollidable = false;
    active = true;
    roamDuration = randomInt(0, 500);
    blownByWind = false;
  }

  @override
  void update(IsometricParticles particles) {

    if (moving && particles.screen.contains(this)){
      particles.render.projectShadow(this);
    }

    if (type == ParticleType.Bat){
      updateBat(particles.scene);
    } else {
      updateButterfly(particles);
    }
  }

  void updateButterfly(IsometricParticles particles) {

    switch (mode) {
      case ButterflyMode.flying:
        if (roamDuration-- <= 0){
          mode = ButterflyMode.landing;
          vx = 0;
          vy = 0;
          targetZ = particles.scene.getProjectionZ(this) + 0.1;
        } else if (closeToTarget){
          changeTarget();
        }
        break;
      case ButterflyMode.landing:
        if (z > targetZ){
          z -= verticalSpeed;
        } else {
          mode = ButterflyMode.landed;
          roamDuration = randomInt(300, 500);
          moving = false;
          stop();
        }
        break;
      case ButterflyMode.landed:
        if (roamDuration-- <= 0){
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
          roamDuration = randomInt(300, 500);
          changeTarget();
        }
    }
  }

  void takeOff() {
    mode = ButterflyMode.takingOff;
    targetZ = z + Node_Height + Node_Height_Half;
    moving = true;
  }

  void updateBat(IsometricScene scene) {

    if (moving){
      moveTowardsTargetVertically();
      if (closeToTargetHorizontally){
        vx = 0;
        vy = 0;
      }
    }

    switch (mode) {
      case ButterflyMode.flying:
        updateBatFlying(scene);
        break;
      case ButterflyMode.landing:
        updateBatLanding();
        break;
      case ButterflyMode.landed:
        updateBatLanded();
        break;
    }
  }

  void updateBatFlying(IsometricScene scene) {
    if (roamDuration-- <= 0){
      setModeLanding(scene);
    } else if (closeToTarget){
      changeTarget();
    }
  }

  void moveTowardsTargetVertically() {
    if (targetZ > z){
      z += verticalSpeedBat;
    } else {
      z -= verticalSpeedBat;
    }
  }

  void setModeLanding(IsometricScene scene) {
    final nearestTreeTop = scene.findNearestNodeType(
      index: this.nodeIndex,
      nodeType: NodeType.Tree_Top,
      radius: 10,
    );
    if (nearestTreeTop == -1) {
      return;
    }

    moving = true;
    mode = ButterflyMode.landing;
    targetX = scene.getIndexPositionX(nearestTreeTop);
    targetY = scene.getIndexPositionY(nearestTreeTop);
    targetZ = scene.getIndexPositionZ(nearestTreeTop);
    faceTargetAndMove();
  }

  @override
  void applyAirFriction() {

  }

  @override
  void changeTarget(){
    super.changeTarget();
    faceTargetAndMove();
  }

  void faceTargetAndMove() {
    rotation = getAngle(targetX, targetY);
    setSpeed(rotation, speed);
    moving = true;
  }

  void updateBatLanding() {
    if (closeToTarget){
      setModeLanded();
    }
  }

  void setModeLanded() {
    mode = ButterflyMode.landed;
    moving = false;
    setRandomDuration(100, 300);
    stop();
  }

  void setRandomDuration(int min, int max) {
    roamDuration = randomInt(min, max);
  }

  void stop() {
    vx = 0;
    vy = 0;
    vz = 0;
  }

  void updateBatLanded() {
     if (roamDuration-- <= 0){
       setBatModeFlying();
     }
  }

  void setBatModeFlying() {
    changeTarget();
    mode = ButterflyMode.flying;
    targetZ = z + Node_Height;
    setRandomDuration(300, 600);
  }

  bool get closeToTargetHorizontally => getDistanceXYSquared(x, y, targetX, targetY) < 8;
}