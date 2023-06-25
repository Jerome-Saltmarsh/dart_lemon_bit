import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_render.dart';
import '../enums/game_dialog.dart';
import '../classes/isometric_position.dart';

class IsometricPlayer {
  var energyPercentage = 0.0;
  var position = IsometricPosition();
  var runningToTarget = false;
  var targetCategory = TargetCategory.Nothing;
  var targetPosition = IsometricPosition();
  var aimTargetCategory = TargetCategory.Nothing;
  var aimTargetType = 0;
  var aimTargetName = '';
  var aimTargetQuantity = 0;
  var aimTargetPosition = IsometricPosition();
  var messageTimer = 0;
  var mouseAngle = 0.0;
  var npcTalk = Watch('');
  var npcTalkOptions = Watch<List<String>>([]);
  var aimTargetChanged = Watch(0);
  var indexZ = 0;
  var indexRow = 0;
  var indexColumn = 0;
  var nodeIndex = 0;

  final id = Watch(0);
  final team = Watch(0);
  final powerType = Watch(CombatPowerType.None);
  final powerReady = Watch(true);
  final attributeHealth = Watch(0);
  final attributeMagic = Watch(0);
  final attributeDamage = Watch(0);
  final body = Watch(0);
  final head = Watch(0);
  final legs = Watch(0);
  final previousPosition = IsometricPosition();
  final storeItems = Watch(<int>[]);
  final energy = Watch(0);
  final energyMax = Watch(0);
  final abilityTarget = IsometricPosition();
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetAllie = Watch<bool>(false);
  final mouseTargetHealth = Watch(0.0);
  final weaponCooldown = Watch(1.0);
  final interpolating = Watch(true);
  final target = IsometricPosition();
  final questAdded = Watch(false);

  late final message = Watch('', onChanged: gamestream.isometric.events.onChangedPlayerMessage);
  late final gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  late final active = Watch(false, onChanged: gamestream.isometric.events.onChangedPlayerActive);
  late final alive = Watch(true, onChanged: gamestream.isometric.events.onChangedPlayerAlive);
  late final weapon = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponPrimary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponSecondary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponTertiary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final respawnTimer = Watch(0);

  int get areaNodeIndex => (indexRow * gamestream.isometric.nodes.totalColumns) + indexColumn;

  double get x => position.x;
  double get y => position.y;
  double get z => position.z;
  double get renderX => IsometricRender.convertV3ToRenderX(position);
  double get renderY => IsometricRender.convertV3ToRenderY(position);
  double get positionScreenX => engine.worldToScreenX(gamestream.isometric.player.position.renderX);
  double get positionScreenY => engine.worldToScreenY(gamestream.isometric.player.position.renderY);

  bool get interactModeTrading => gamestream.isometric.server.interactMode.value == InteractMode.Trading;
  bool get dead => !alive.value;
  bool get inBounds => gamestream.isometric.nodes.inBoundsVector3(position);


  bool isCharacter(IsometricCharacter character){
    return position.x == character.x && position.y == character.y && position.z == character.z;
  }

  void onChangedGameDialog(GameDialog? value){
    gamestream.audio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }

  bool isInsideBuilding(){
    if (!inBounds) return false;
    final index = position.nodeIndex + gamestream.isometric.nodes.area;
    while (index < gamestream.isometric.nodes.total){
      if (NodeType.isRainOrEmpty(gamestream.isometric.nodes.nodeTypes[index]))  continue;
      return true;
    }
    return false;
  }

  Watch<int> getItemTypeWatch(int itemType){
    if (ItemType.isTypeWeapon(itemType)) return weapon;
    if (ItemType.isTypeHead(itemType)) return head;
    if (ItemType.isTypeBody(itemType)) return body;
    if (ItemType.isTypeLegs(itemType)) return legs;
    throw Exception(
        'gamestream.isometricEngine.player.getItemTypeWatch(${ItemType.getName(itemType)})'
    );
  }

  void updateMessageTimer() {
    if (messageTimer <= 0)
      return;
    messageTimer--;
    if (messageTimer > 0)
      return;
    message.value = '';
  }
}

typedef ItemTypeEntry = MapEntry<int, int>;