

import 'dart:math';


import 'package:lemon_math/src.dart';
import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_particles.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_scene.dart';

class FlyMode {
  static const flying = 0;
  static const landing = 1;
  static const landed = 2;
  static const takingOff = 3;
}

/// flying
/// landing
/// landed
/// taking-off
class ParticleFlying extends ParticleRoam {

  var speed = 3.0;
  var moving = false;
  var roamDuration = 0;
  var mode = FlyMode.flying;
  var shadowScale = 1.0;

  static const changeTargetRadius = 5.0;
  static const verticalSpeed = 3.0;
  static const verticalSpeedBat = 0.6;

  ParticleFlying({required super.x, required super.y, required super.z}) {
    type = ParticleType.Butterfly;
    startX = x;
    startY = y;
    startZ = z;
    durationTotal = -1;
    // nodeCollidable = false;
    roamDuration = randomInt(0, 500);
    blownByWind = false;
  }

  @override
  void update(IsometricParticles particles) {

    if (moving && particles.screen.contains(this)){
      particles.render.projectShadow(this, scale: shadowScale);
    }

    if (type == ParticleType.Bat){
      updateBat(particles.scene);
    } else {
      updateButterfly(particles);
    }
  }

  void updateButterfly(IsometricParticles particles) {

    switch (mode) {
      case FlyMode.flying:
        if (roamDuration-- <= 0){
          mode = FlyMode.landing;
          vx = 0;
          vy = 0;
          targetZ = particles.scene.getProjectionZ(this) + 0.1;
        } else if (closeToTarget){
          changeTarget();
        }
        break;
      case FlyMode.landing:
        if (z > targetZ){
          z -= verticalSpeed;
        } else {
          mode = FlyMode.landed;
          roamDuration = randomInt(300, 500);
          moving = false;
          stop();
        }
        break;
      case FlyMode.landed:
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
      case FlyMode.takingOff:
        if (z < targetZ){
          z += verticalSpeed;
        } else {
          mode = FlyMode.flying;
          roamDuration = randomInt(300, 500);
          changeTarget();
        }
    }
  }

  void takeOff() {
    mode = FlyMode.takingOff;
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
      case FlyMode.flying:
        updateBatFlying(scene);
        break;
      case FlyMode.landing:
        updateBatLanding();
        break;
      case FlyMode.landed:
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
    mode = FlyMode.landing;
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
    rotation = getAngle(targetX, targetY) + pi;
    setSpeed(rotation, speed);
    moving = true;
  }

  void updateBatLanding() {
    if (closeToTarget){
      setModeLanded();
    }
  }

  void setModeLanded() {
    mode = FlyMode.landed;
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
    mode = FlyMode.flying;
    targetZ = z + Node_Height;
    setRandomDuration(300, 600);
  }

  bool get closeToTargetHorizontally => getDistanceXYSquared(x, y, targetX, targetY) < 8;
}