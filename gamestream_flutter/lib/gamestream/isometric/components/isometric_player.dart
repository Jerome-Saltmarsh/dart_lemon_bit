import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_watch/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/packages/lemon_components.dart';

import '../enums/game_dialog.dart';
import '../../../isometric/classes/position.dart';

class IsometricPlayer with IsometricComponent implements Updatable {

  var energyPercentage = 0.0;
  var runningToTarget = false;
  var aimTargetType = 0;
  var aimTargetQuantity = 0;
  var messageTimer = 0;
  var mouseAngle = 0.0;
  var indexZ = 0;
  var indexRow = 0;
  var indexColumn = 0;
  var nodeIndex = 0;
  var runX = 0.0;
  var runY = 0.0;
  var runZ = 0.0;
  var areaNodeIndex = 0;

  final name = Watch('');
  final runToDestinationEnabled = Watch(false);
  final arrivedAtDestination = Watch(false);
  final aimTargetSet = Watch(false);
  final aimTargetName = Watch('');
  final aimTargetHealthPercentage = Watch(0.0);
  final aimTargetAction = Watch(TargetAction.Run);
  final npcTalk = Watch('');
  final aimTargetPosition = Position();
  final targetPosition = Position();
  final position = Position();
  final npcTalkOptions = Watch<List<String>>([]);
  final aimTargetChanged = Watch(0);
  final id = Watch(0);
  final team = Watch(0);
  final headType = Watch(0);
  final helmType = Watch(0);
  final hairType = Watch(0);
  final hairColor = Watch(0);
  final shoeType = Watch(0);
  final gender = Watch(0);
  final bodyType = Watch(0);
  final legsType = Watch(0);
  final handTypeLeft = Watch(0);
  final handTypeRight = Watch(0);
  final complexion = Watch(0);
  final previousPosition = Position();
  final accuracy = Watch(1.0);
  final energy = Watch(0);
  final energyMax = Watch(0);
  final abilityTarget = Position();
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetAllie = Watch<bool>(false);
  final mouseTargetHealth = Watch(0.0);
  final target = Position();
  final health = Watch(0);
  final maxHealth = Watch(0);
  final weaponDamage = Watch(0);
  final weaponCooldown = Watch(1.0);
  final credits = Watch(0);
  final controlsCanTargetEnemies = Watch(false);
  final controlsRunInDirectionEnabled = Watch(false);

  late final message = Watch('');
  late final gameDialog = Watch<GameDialog?>(
      null, onChanged: onChangedGameDialog);
  late final active = Watch(false);
  late final alive = Watch(true);
  late final weaponType = Watch(0);
  late final debugging = Watch(false, onChanged: onChangedDebugging);

  IsometricPlayer() {
    legsType.onChanged((t) {
      print('player.legsType(${LegType.getName(t)})');
    });

    aimTargetSet.onChanged((aimTargetSet) {
      if (aimTargetSet){
        ui.cursor.value = SystemMouseCursors.grab;
      } else {
        ui.cursor.value = SystemMouseCursors.basic;
        // engine.setCursorCrosshair();
      }
    });
  }


  double get x => position.x;

  double get y => position.y;

  double get z => position.z;

  double get renderX => position.renderX;

  double get renderY => position.renderY;

  double get positionScreenX => engine.worldToScreenX(position.renderX);

  double get positionScreenY => engine.worldToScreenY(position.renderY);

  bool get dead => !alive.value;

  bool get inBounds => scene.inBoundsPosition(position);

  Color get skinColor => colors.palette[complexion.value];

  bool isCharacter(Character character) {
    return position.x == character.x && position.y == character.y &&
        position.z == character.z;
  }

  void onChangedGameDialog(GameDialog? value) {
    audio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }

  bool isInsideBuilding() {
    if (!inBounds) return false;
    final index = nodeIndex + scene.area;
    while (index < scene.totalNodes) {
      if (NodeType.isRainOrEmpty(scene.nodeTypes[index])) continue;
      return true;
    }
    return false;
  }

  void onComponentUpdate() {
    updateMessageTimer();
  }

  void updateMessageTimer() {
    if (messageTimer <= 0)
      return;
    messageTimer--;
    if (messageTimer > 0)
      return;
    message.value = '';
  }

  void savePositionPrevious() {
    previousPosition.x = position.x;
    previousPosition.y = position.y;
    previousPosition.z = position.z;
  }

  void onChangedDebugging(bool debugging) {
    if (!debugging) {
      action.cameraTargetPlayer();
    }
  }

  void toggleControlsCanTargetEnemies() =>
      network.sendIsometricRequest(
          NetworkRequestIsometric.Toggle_Controls_Can_Target_Enemies
      );

  void onPlayerInitialized() {
    position.x = 0;
    position.y = 0;
    position.z = 0;
    previousPosition.x = 0;
    previousPosition.y = 0;
    previousPosition.z = 0;
    indexZ = 0;
    indexRow = 0;
    indexColumn = 0;
    scene.characters.clear();
    scene.projectiles.clear();
    scene.gameObjects.clear();
    scene.totalProjectiles = 0;
    scene.totalCharacters = 0;
  }

  void readNetworkResponsePlayer() {
    switch (parser.readByte()) {
      case NetworkResponsePlayer.HeadType:
        readHeadType();
        break;
      case NetworkResponsePlayer.BodyType:
        readBodyType();
        break;
      case NetworkResponsePlayer.LegsType:
        readLegsType();
        break;
      case NetworkResponsePlayer.HandTypeLeft:
        readHandTypeLeft();
        break;
      case NetworkResponsePlayer.HandTypeRight:
        readHandTypeRight();
        break;
      case NetworkResponsePlayer.HairType:
        readHairType();
        break;
      case NetworkResponsePlayer.HairColor:
        readHairColor();
        break;
      case NetworkResponsePlayer.ShoeType:
        readShoeType();
        break;
      case NetworkResponsePlayer.Gender:
        readGender();
        break;
      case NetworkResponsePlayer.HelmType:
        readHelmType();
        break;
      case NetworkResponsePlayer.WeaponType:
        readWeaponType();
        break;
      case NetworkResponsePlayer.Complexion:
        complexion.value = parser.readByte();
        break;
      case NetworkResponsePlayer.Name:
        name.value = parser.readString();
        break;
      case NetworkResponsePlayer.Aim_Target_Health:
        aimTargetHealthPercentage.value = parser.readPercentage();
        break;
      case NetworkResponsePlayer.Aim_Target_Action:
        aimTargetAction.value = parser.readByte();
        break;
      case NetworkResponsePlayer.Aim_Target_Position:
        parser.readIsometricPosition(aimTargetPosition);
        break;
      case NetworkResponsePlayer.Health:
        parser.readPlayerHealth();
        break;
      case NetworkResponsePlayer.Alive:
        alive.value = parser.readBool();
        break;
      case NetworkResponsePlayer.Aim_Angle:
        mouseAngle = parser.readAngle();
        break;
      case NetworkResponsePlayer.Message:
        message.value = parser.readString();
        break;
      case NetworkResponsePlayer.Aim_Target_Type:
        aimTargetType = parser.readUInt16();
        break;
      case NetworkResponsePlayer.Aim_Target_Quantity:
        aimTargetQuantity = parser.readUInt16();
        break;
      case NetworkResponsePlayer.Target_Position:
        runningToTarget = true;
        parser.readIsometricPosition(targetPosition);
        break;
      case NetworkResponsePlayer.Weapon_Damage:
        weaponDamage.value = parser.readUInt16();
        break;
      case NetworkResponsePlayer.Id:
        id.value = parser.readUInt24();
        break;
      case NetworkResponsePlayer.Active:
        active.value = parser.readBool();
        break;
      case NetworkResponsePlayer.Team:
        player.team.value = parser.readByte();
        break;
      case NetworkResponsePlayer.Position:
        final position = player.position;
        position.x = parser.readInt16().toDouble();
        position.y = parser.readInt16().toDouble();
        position.z = parser.readInt16().toDouble();
        break;
      case NetworkResponsePlayer.Destination:
        player.runX = parser.readDouble();
        player.runY = parser.readDouble();
        player.runZ = parser.readDouble();
        break;
      case NetworkResponsePlayer.Arrived_At_Destination:
        player.arrivedAtDestination.value = parser.readBool();
        break;
      case NetworkResponsePlayer.Run_To_Destination_Enabled:
        player.runToDestinationEnabled.value = parser.readBool();
        break;
      case NetworkResponsePlayer.Debugging:
        player.debugging.value = parser.readBool();
        break;
    }
  }

  void readHandTypeRight() {
    handTypeRight.value = parser.readByte();
  }

  void readHandTypeLeft() {
    handTypeLeft.value = parser.readByte();
  }

  void readLegsType() {
    legsType.value = parser.readByte();
  }

  void readBodyType() {
    bodyType.value = parser.readByte();
  }

  void readHeadType() {
    headType.value = parser.readByte();
  }

  void readHelmType() {
    helmType.value = parser.readByte();
  }

  void readWeaponType() {
    weaponType.value = parser.readByte();
  }

  void showDialogChangeComplexion() =>
      ui.showDialogGetColor(
          onSelected: sendRequestSetComplexion
      );

  void showDialogChangeHairColor() =>
      ui.showDialogGetColor(
          onSelected: setHairColor
      );

  void showDialogChangeHairType() =>
      ui.showDialogGetHairType(
          onSelected: setHairType
      );

  void changeName() =>
      ui.showDialogGetString(
        onSelected: sendRequestSetName,
        text: name.value,
      );

  void sendRequestSetName(String name) {
    network.sendRequest(
      NetworkRequest.Player,
      NetworkRequestPlayer.setName.index,
      name,
    );
  }

  void setComplexion(Color color) {
    final index = colors.palette.indexOf(color);
    if (index == -1) {
      return;
    }
    network.sendRequest(
      NetworkRequest.Player,
      NetworkRequestPlayer.setComplexion.index,
      index,
    );
  }

  void sendRequestSetComplexion(int index) {
    if (index == -1) {
      return;
    }
    network.sendRequest(
      NetworkRequest.Player,
      NetworkRequestPlayer.setComplexion.index,
      index,
    );
  }

  void readHairType() {
    hairType.value = parser.readByte();
  }

  void readHairColor() => hairColor.value = parser.readByte();

  void readShoeType() => shoeType.value = parser.readByte();

  void readGender() => gender.value = parser.readByte();

  void setHairType(int hairType) =>
      network.sendNetworkRequest(
        NetworkRequest.Player,
        NetworkRequestPlayer.setHairType.index,
        hairType,
      );

  void setHairColor(int value) =>
      network.sendNetworkRequest(
        NetworkRequest.Player,
        NetworkRequestPlayer.setHairColor.index,
        value,
      );

  void toggleGender() =>
      network.sendNetworkRequest(
        NetworkRequest.Player,
        NetworkRequestPlayer.toggleGender.index,
      );

  void setGender(int gender) =>
      network.sendNetworkRequest(
        NetworkRequest.Player,
        NetworkRequestPlayer.setGender.index,
        gender,
      );

  void setHeadType(int value) =>
      network.sendNetworkRequest(
        NetworkRequest.Player,
        NetworkRequestPlayer.setHeadType.index,
        value,
      );
}
