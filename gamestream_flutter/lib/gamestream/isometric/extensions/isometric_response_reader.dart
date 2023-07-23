

import 'dart:typed_data';
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_events.dart';

extension IsometricResponseReader on Gamestream {

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
        final player = isometric.player;
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
        player.nodeIndex = isometric.getIndexPosition(position);
        break;

      case IsometricResponse.Player_Accuracy:
        isometric.player.accuracy.value = readPercentage();
        break;

      case IsometricResponse.Player_Weapon_Duration_Percentage:
        isometric.player.weaponCooldown.value = readPercentage();
        break;

      case IsometricResponse.GameObjects:
        isometric.gameObjects.clear();
        break;

      case IsometricResponse.Player_Initialized:
        isometric.onPlayerInitialized();
        break;

      case IsometricResponse.Player_Controls:
        isometric.player.controlsCanTargetEnemies.value = readBool();
        isometric.player.controlsRunInDirectionEnabled.value = readBool();
        break;
    }
  }


  void readSelectedCollider() {
    final debug = isometric.debug;
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
    isometric.totalZ = readUInt16();
    isometric.totalRows = readUInt16();
    isometric.totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();

    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);
    final nodeTypes = decoder.decodeBytes(compressedNodeTypes);

    isometric.nodeTypes = Uint8List.fromList(nodeTypes);
    isometric.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    isometric.area = isometric.totalRows * isometric.totalColumns;
    isometric.area2 = isometric.area * 2;
    isometric.projection = isometric.area2 + isometric.totalColumns + 1;
    isometric.projectionHalf =  isometric.projection ~/ 2;
    final totalNodes = isometric.totalZ * isometric.totalRows * isometric.totalColumns;
    isometric.colorStack = Uint16List(totalNodes);
    isometric.ambientStack = Uint16List(totalNodes);
    isometric.totalNodes = totalNodes;
    isometric.nodesRaycast = isometric.area +  isometric.area + isometric.totalColumns + 1;
    isometric.onChangedNodes();
    isometric.refreshNodeVariations();
    isometric.nodesChangedNotifier.value++;
    isometric.particles.clear();
    io.recenterCursor();
  }

  void readIsometricPlayerPosition() {
    final player = isometric.player;
    final position = player.position;
    player.savePositionPrevious();
    readIsometricPosition(position);
    player.indexColumn = position.indexColumn;
    player.indexRow = position.indexRow;
    player.indexZ = position.indexZ;
    player.nodeIndex = isometric.getIndexPosition(position);
  }

  void readPlayerAimTarget() {
    final player = isometric.player;
    final aimTargetSet = readBool();
    player.playerAimTargetSet.value = aimTargetSet;
    if (aimTargetSet) {
      player.playerAimTargetName.value = readString();
    } else {
      player.playerAimTargetName.value = '';
    }
  }

}