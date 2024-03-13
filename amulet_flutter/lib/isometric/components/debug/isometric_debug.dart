
import 'dart:typed_data';
import 'package:amulet_common/src.dart';
import 'package:amulet_flutter/isometric/classes/particle_roam.dart';
import 'package:amulet_flutter/packages/lemon_components/updatable.dart';
import 'package:flutter/services.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/isometric/classes/particle.dart';
import 'package:amulet_flutter/isometric/classes/position.dart';
import 'package:amulet_flutter/isometric/components/debug/debug_tab.dart';
import 'package:amulet_flutter/isometric/classes/particle_whisp.dart';

class IsometricDebug with IsometricComponent implements Updatable {
  Particle? particleSelected;

  final tab = Watch(DebugTab.Selected);
  final health = Watch(0);
  final healthMax = Watch(0);
  final radius = Watch(0);
  final position = Position();
  final destinationX = Watch(0.0);
  final destinationY = Watch(0.0);
  final x = Watch(0.0);
  final y = Watch(0.0);
  final z = Watch(0.0);
  final team = Watch(0);
  final runTimeType = Watch('');
  final path = Uint16List(500);
  final pathIndex = Watch(0);
  final pathEnd = Watch(0);
  final characterAction = Watch(0);
  final goal = Watch(0);
  final pathTargetIndex = Watch(0);
  final targetSet = Watch(false);
  final targetType = Watch('');
  final targetX = Watch(0.0);
  final targetY = Watch(0.0);
  final targetZ = Watch(0.0);

  final characterType = Watch(0);
  final characterState = Watch(0);
  final characterComplexion = Watch(0);
  final characterStateDuration = Watch(0);
  final characterStateDurationRemaining = Watch(0);

  final weaponType = Watch(0);
  final weaponDamage = Watch(0);
  final weaponRange = Watch(0);
  final weaponState = Watch(0);
  final weaponStateDuration = Watch(0);
  final autoAttack = Watch(false);
  final pathFindingEnabled = Watch(false);
  final runToDestinationEnabled = Watch(false);
  final arrivedAtDestination = Watch(false);
  final selectedColliderType = Watch(-1);

  final selectedGameObjectType = Watch(-1);
  final selectedGameObjectSubType = Watch(-1);
  final selectedCollider = Watch(false);

  // final itemSlotWeapon = ItemSlot(slotType: SlotType.Weapons, index: 0);
  // final itemSlotPower = ItemSlot(slotType: SlotType.Weapons, index: 0);

  void drawCanvas() {
    if (!options.debugging) return;
    renderSelectedParticle();
    renderSelectedCollider();
  }

  void renderSelectedParticle() {
    final particle = particleSelected;
    if (particle == null) return;
    engine.setPaintColor(Colors.white);
    render.circleOutlineAtPosition(position: particle, radius: 10);

    engine.setPaintColor(colors.white60);

    if (particle is ParticleRoam){
      render.circleOutline(
        x: particle.startX,
        y: particle.startY,
        z: particle.startZ,
        radius: particle.roamRadius,
      );

      render.line(
        particle.x,
        particle.y,
        particle.z,
        particle.targetX,
        particle.targetY,
        particle.targetZ,
      );
    }

    if (particle is ParticleWhisp){

      engine.setPaintColor(colors.blue_0);
      render.line(
          particle.x,
          particle.y,
          particle.z,
          particle.x + adj(particle.movementAngle, 15),
          particle.y + opp(particle.movementAngle, 15),
          particle.z,
      );
    }

    engine.setPaintColor(Colors.white);
  }

  void renderSelectedCollider() {
    if (!selectedCollider.value)
      return;

    engine.setPaintColor(Colors.white);
    render.circleOutline(
      x: x.value,
      y: y.value,
      z: z.value,
      radius: radius.value.toDouble(),
    );

    engine.setPaintColor(Colors.green);
    render.circleOutline(
      x: x.value,
      y: y.value,
      z: z.value,
      radius: weaponRange.value.toDouble(),
    );

    engine.setPaintColor(Colors.red);
    if (selectedColliderType.value == IsometricType.Character) {
      if (targetSet.value) {
        render.line(
          x.value,
          y.value,
          z.value,
          targetX.value,
          targetY.value,
          targetZ.value,
        );
      }

      engine.setPaintColor(Colors.blue);
      renderPath(
        path: path,
        start: 0,
        end: pathIndex.value,
      );

      engine.setPaintColor(Colors.yellow);
      renderPath(
        path: path,
        start: pathIndex.value,
        end: pathEnd.value,
      );

      if (!arrivedAtDestination.value){
        engine.setPaintColor(Colors.deepPurpleAccent);
        render.line(
          x.value,
          y.value,
          z.value,
          destinationX.value,
          destinationY.value,
          z.value,
        );
      }


      final pathTargetIndexValue = pathTargetIndex.value;
      if (pathTargetIndexValue != -1) {
        render.wireFrameBlue(
          scene.getIndexZ(pathTargetIndexValue),
          scene.getRow(pathTargetIndexValue),
          scene.getColumn(pathTargetIndexValue),
        );
      }
    }
  }

  void renderPath({
    required Uint16List path,
    required int start,
    required int end,
  }){
    if (start < 0) return;
    if (end < 0) return;
    for (var i = start; i < end - 1; i++){
      final a = path[i];
      final b = path[i + 1];
      engine.drawLine(
        scene.getIndexRenderX(a) + Node_Size_Half,
        scene.getIndexRenderY(a) + Node_Size_Half,
        scene.getIndexRenderX(b) + Node_Size_Half,
        scene.getIndexRenderY(b) + Node_Size_Half,
      );
    }
  }

  void update(){
     switch (tab.value){
       case DebugTab.Selected:
         if (selectedCollider.value){
           options.cameraDebug.copy(position);
         }
         break;
       default:
         break;
     }
  }

  void onMouseLeftClicked() {
    if (tab.value == DebugTab.Particles){
      selectNearestParticleToMouse();
    } else {
      server.sendIsometricRequestDebugSelect();
    }
  }

  void selectNearestParticleToMouse() {
    final nearestParticle = getParticleNearestToMouse();
    if (nearestParticle != null){
      selectParticle(nearestParticle);
    }
  }


  void onMouseRightClicked() {

    switch (tab.value) {
      case DebugTab.Selected:

        break;
      default:
        break;
    }

    if (engine.keyPressedShiftLeft){
      server.sendIsometricRequestDebugAttack();
      return;
    }
    server.sendIsometricRequestDebugCommand();
  }

  void onKeyPressed(PhysicalKeyboardKey key){
    if (key == PhysicalKeyboardKey.keyG) {
      sendIsometricRequestMoveSelectedColliderToMouse();
      return;
    }
  }

  void selectParticle(Particle particle){
    camera.target = particle;
    particleSelected = particle;
  }

  void sendIsometricRequestMoveSelectedColliderToMouse() =>
      server.sendIsometricRequest(
          NetworkRequestIsometric.Move_Selected_Collider_To_Mouse
      );

  void sendIsometricRequestDebugCharacterWalkToMouse() =>
      server.sendIsometricRequest(
          NetworkRequestIsometric.Debug_Character_Walk_To_Mouse
      );

  void sendIsometricRequestDebugCharacterToggleAutoAttackNearbyEnemies() =>
      server.sendIsometricRequest(
          NetworkRequestIsometric.Debug_Character_Toggle_Auto_Attack_Nearby_Enemies
      );

  void sendIsometricRequestDebugCharacterTogglePathFindingEnabled() =>
      server.sendIsometricRequest(
          NetworkRequestIsometric.Debug_Character_Toggle_Path_Finding_Enabled
      );

  void sendIsometricRequestDebugCharacterToggleRunToDestination() =>
      server.sendIsometricRequest(
          NetworkRequestIsometric.Debug_Character_Toggle_Run_To_Destination
      );

  void sendIsometricRequestDebugCharacterDebugUpdate() =>
      server.sendIsometricRequest(
          NetworkRequestIsometric.Debug_Character_Debug_Update
      );

  Particle? getParticleNearestToMouse() {

    if (particles.activated.isEmpty)
      return null;

    var nearest = particles.activated.first;
    var nearestDistance = mouse.getRenderDistanceSquare(nearest);

    for (final particle in particles.activated){
      final distance = mouse.getRenderDistanceSquare(particle);

      if (distance >= nearestDistance)
        continue;

      nearest = particle;
      nearestDistance = distance;
    }

    return nearest;
  }

  @override
  void onComponentUpdate() {
    if (!options.debugging){
      return;
    }

    final cameraDebug = options.cameraDebug;
    switch (tab.value){
      case DebugTab.Selected:
        if (selectedCollider.value){
          cameraDebug.x = position.x;
          cameraDebug.y = position.y;
          cameraDebug.z = position.z;
        } else {
          cameraDebug.x = player.x;
          cameraDebug.y = player.y;
          cameraDebug.z = player.z;
        }
        break;
      default:
        break;
    }
  }
}