import 'package:gamestream_flutter/gamestream/isometric/components/mixins/component_isometric.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/library.dart';

import '../enums/game_dialog.dart';
import '../../../isometric/classes/position.dart';

class IsometricPlayer with IsometricComponent {

  var playerInsideIsland = false;
  var energyPercentage = 0.0;
  var runningToTarget = false;
  var aimTargetCategory = TargetCategory.Nothing;
  var aimTargetType = 0;
  var aimTargetName = '';
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

  late final debugging = Watch(false, onChanged: onChangedDebugging);
  final runToDestinationEnabled = Watch(false);
  final arrivedAtDestination = Watch(false);
  final playerAimTargetSet = Watch(false);
  final playerAimTargetName = Watch('');
  final npcTalk = Watch('');
  final aimTargetPosition = Position();
  final targetPosition = Position();
  final position = Position();
  final npcTalkOptions = Watch<List<String>>([]);
  final aimTargetChanged = Watch(0);
  final id = Watch(0);
  final team = Watch(0);
  final body = Watch(0);
  final head = Watch(0);
  final legs = Watch(0);
  final previousPosition = Position();
  final accuracy = Watch(1.0);
  final storeItems = Watch(<int>[]);
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
  late final gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  late final active = Watch(false);
  late final alive = Watch(true);
  late final weapon = Watch(0);

  double get x => position.x;
  double get y => position.y;
  double get z => position.z;

  double get renderX => position.renderX;
  double get renderY => position.renderY;

  double get positionScreenX => isometric.engine.worldToScreenX(position.renderX);
  double get positionScreenY => isometric.engine.worldToScreenY(position.renderY);

  bool get dead => !alive.value;
  bool get inBounds => isometric.scene.inBoundsPosition(position);


  bool isCharacter(Character character){
    return position.x == character.x && position.y == character.y && position.z == character.z;
  }

  void onChangedGameDialog(GameDialog? value){
    audio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }

  bool isInsideBuilding(){
    if (!inBounds) return false;
    final index = nodeIndex + isometric.scene.area;
    while (index < isometric.scene.totalNodes){
      if (NodeType.isRainOrEmpty(isometric.scene.nodeTypes[index])) continue;
      return true;
    }
    return false;
  }

  Watch<int> getItemTypeWatch(int itemType){
    // if (ItemType.isTypeWeapon(itemType)) return weapon;
    // if (ItemType.isTypeHead(itemType)) return head;
    // if (ItemType.isTypeBody(itemType)) return body;
    // if (ItemType.isTypeLegs(itemType)) return legs;
    throw Exception(
        'gamestream.isometricEngine.player.getItemTypeWatch($itemType)'
    );
  }

  void update(){
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

  void savePositionPrevious(){
    previousPosition.x = position.x;
    previousPosition.y = position.y;
    previousPosition.z = position.z;
  }

  void onChangedDebugging(bool debugging){
    if (!debugging){
      action.cameraTargetPlayer();
    }
  }

  void toggleControlsRunInDirectionEnabled() =>
      network.sendIsometricRequest(IsometricRequest.Toggle_Controls_Run_In_Direction_Enabled);

  void toggleControlsCanTargetEnemies() =>
      network.sendIsometricRequest(IsometricRequest.Toggle_Controls_Can_Target_Enemies);
}

typedef ItemTypeEntry = MapEntry<int, int>;