

import 'dart:typed_data';
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_events.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

extension IsometricResponseReader on Isometric {

  void readIsometricResponse() {
    switch (readByte()) {

      case IsometricResponse.Selected_Collider:
        readSelectedCollider();
        break;

      case IsometricResponse.Scene:
        readScene();
        break;

      case IsometricResponse.Player_Position:
        readIsometricPlayerPosition();
        break;

      case IsometricResponse.Player_Aim_Target:
        readPlayerAimTarget();
        break;

      case IsometricResponse.Player_Position_Change:
        final position = player.position;
        player.savePositionPrevious();
        final changeX = readInt8().toDouble();
        final changeY = readInt8().toDouble();
        final changeZ = readInt8().toDouble();
        position.x += changeX;
        position.y += changeY;
        position.z += changeZ;
        player.indexColumn = position.indexColumn;
        player.indexRow = position.indexRow;
        player.indexZ = position.indexZ;
        player.nodeIndex = getIndexPosition(position);
        break;

      case IsometricResponse.Player_Accuracy:
        player.accuracy.value = readPercentage();
        break;

      case IsometricResponse.Player_Weapon_Duration_Percentage:
        player.weaponCooldown.value = readPercentage();
        break;

      case IsometricResponse.GameObjects:
        gameObjects.clear();
        break;

      case IsometricResponse.Player_Initialized:
        onPlayerInitialized();
        break;

      case IsometricResponse.Player_Controls:
        player.controlsCanTargetEnemies.value = readBool();
        player.controlsRunInDirectionEnabled.value = readBool();
        break;
    }
  }


  void readSelectedCollider() {
    debug.selectedCollider.value = readBool();

    if (!debug.selectedCollider.value)
      return;

    final selectedColliderType = readByte();
    debug.selectedColliderType.value = selectedColliderType;

    if (selectedColliderType == IsometricType.GameObject) {
      debug.runTimeType.value = readString();
      debug.team.value = readUInt16();
      debug.radius.value = readUInt16();
      debug.health.value = readUInt16();
      debug.healthMax.value = readUInt16();
      debug.x.value = readDouble();
      debug.y.value = readDouble();
      debug.z.value = readDouble();
      debug.position.x = debug.x.value;
      debug.position.y = debug.y.value;
      debug.position.z = debug.z.value;
      debug.selectedGameObjectType.value = readByte();
      debug.selectedGameObjectSubType.value = readByte();
      return;
    }

    if (selectedColliderType == IsometricType.Character){
      debug.runTimeType.value = readString();
      debug.action.value = readByte();
      debug.goal.value = readByte();
      debug.team.value = readUInt16();
      debug.radius.value = readUInt16();
      debug.health.value = readUInt16();
      debug.healthMax.value = readUInt16();
      debug.x.value = readDouble();
      debug.y.value = readDouble();
      debug.z.value = readDouble();
      debug.position.x = debug.x.value;
      debug.position.y = debug.y.value;
      debug.position.z = debug.z.value;
      debug.destinationX.value = readDouble();
      debug.destinationY.value = readDouble();
      debug.pathIndex.value = readInt16();
      debug.pathEnd.value = readInt16();
      debug.pathTargetIndex.value = readInt16();
      for (var i = 0; i < debug.pathEnd.value; i++) {
        debug.path[i] = readUInt16();
      }

      debug.characterType.value = readByte();
      debug.characterState.value = readByte();
      debug.characterStateDuration.value = readInt16();
      debug.characterStateDurationRemaining.value = readUInt16();

      debug.weaponType.value = readUInt16();
      debug.weaponDamage.value = readUInt16();
      debug.weaponRange.value = readUInt16();
      debug.weaponState.value = readByte();
      debug.weaponStateDuration.value = readUInt16();

      debug.autoAttack.value = readBool();
      debug.pathFindingEnabled.value = readBool();
      debug.runToDestinationEnabled.value = readBool();
      debug.arrivedAtDestination.value = readBool();

      final characterSelectedTarget = readBool();
      debug.targetSet.value = characterSelectedTarget;
      if (!characterSelectedTarget) return;
      debug.targetType.value = readString();
      debug.targetX.value = readDouble();
      debug.targetY.value = readDouble();
      debug.targetZ.value = readDouble();
    }
  }

  void readScene() {
    final scenePart = readByte(); /// DO NOT DELETE
    totalZ = readUInt16();
    totalRows = readUInt16();
    totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();

    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);

    nodeTypes = Uint8List.fromList(decoder.decodeBytes(compressedNodeTypes));
    nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    area = totalRows * totalColumns;
    area2 = area * 2;
    projection = area2 + totalColumns + 1;
    projectionHalf =  projection ~/ 2;
    totalNodes = totalZ * totalRows * totalColumns;
    colorStack = Uint16List(totalNodes);
    ambientStack = Uint16List(totalNodes);
    totalNodes = totalNodes;
    nodesRaycast = area +  area + totalColumns + 1;
    onChangedNodes();
    refreshNodeVariations();
    nodesChangedNotifier.value++;
    particles.clear();
    io.recenterCursor();
  }

  void readIsometricPlayerPosition() {
    final position = player.position;
    player.savePositionPrevious();
    readIsometricPosition(position);
    player.indexColumn = position.indexColumn;
    player.indexRow = position.indexRow;
    player.indexZ = position.indexZ;
    player.nodeIndex = getIndexPosition(position);
    player.areaNodeIndex = (position.indexRow * totalColumns) + position.indexColumn;
  }

  void readPlayerAimTarget() {
    final aimTargetSet = readBool();
    player.playerAimTargetSet.value = aimTargetSet;
    if (aimTargetSet) {
      player.playerAimTargetName.value = readString();
    } else {
      player.playerAimTargetName.value = '';
    }
  }


  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Rain:
        rainType.value = readByte();
        break;
      case EnvironmentResponse.Lightning:
        lightningType.value = readByte();
        break;
      case EnvironmentResponse.Wind:
        windTypeAmbient.value = readByte();
        break;
      case EnvironmentResponse.Breeze:
        weatherBreeze.value = readBool();
        break;
      case EnvironmentResponse.Underground:
        sceneUnderground.value = readBool();
        break;
      case EnvironmentResponse.Lightning_Flashing:
        lightningFlashing.value = readBool();
        break;
      case EnvironmentResponse.Time_Enabled:
        gameTimeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final id = readUInt16();
    final gameObject = findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readByte();
    gameObject.subType = readByte();
    gameObject.health = readUInt16();
    gameObject.maxHealth = readUInt16();
    readIsometricPosition(gameObject);
    gameObjects.sort();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Aim_Target_Category:
        player.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readIsometricPosition(player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        player.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        player.aimTargetName = readString();
        break;
      case ApiPlayer.Arrived_At_Destination:
        player.arrivedAtDestination.value = readBool();
        break;
      case ApiPlayer.Run_To_Destination_Enabled:
        player.runToDestinationEnabled.value = readBool();
        break;
      case ApiPlayer.Debugging:
        player.debugging.value = readBool();
        break;
      case ApiPlayer.Destination:
        player.runX = readDouble();
        player.runY = readDouble();
        player.runZ = readDouble();
        break;
      case ApiPlayer.Target_Position:
        player.runningToTarget = true;
        readIsometricPosition(player.targetPosition);
        break;
      case ApiPlayer.Experience_Percentage:
        playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Aim_Angle:
        player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Message:
        player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        player.alive.value = readBool();
        // isometric.ui.mouseOverDialog.setFalse();
        break;
      case ApiPlayer.Spawned:
        camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        player.weaponDamage.value = readUInt16();
        break;
      case ApiPlayer.Id:
        player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        player.active.value = readBool();
        break;
      case ApiPlayer.Team:
        player.team.value = readByte();
        break;
      default:
        throw Exception('Cannot parse apiPlayer $apiPlayer');
    }
  }

  void readMap(Map<int, int> map){
    final length = readUInt16();
    map.clear();
    for (var i = 0; i < length; i++) {
      final key = readUInt16();
      final value = readUInt16();
      map[key] = value;
    }
  }

}