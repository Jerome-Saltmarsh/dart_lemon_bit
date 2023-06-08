import 'package:gamestream_flutter/library.dart';

import '../games/isometric/game_isometric_renderer.dart';
import 'isometric_position.dart';

class IsometricPlayer {
  final id = Watch(0);
  final perkType = Watch(PerkType.None);
  final powerType = Watch(PowerType.None);
  final powerReady = Watch(true);
  late final weapon = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponPrimary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponSecondary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponTertiary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final respawnTimer = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerRespawnTimer);

  final attributeHealth = Watch(0);
  final attributeMagic = Watch(0);
  final attributeDamage = Watch(0);

  final body = Watch(0);
  final head = Watch(0);
  final legs = Watch(0);
  late final active = Watch(false, onChanged: gamestream.isometric.events.onChangedPlayerActive);
  late final alive = Watch(true, onChanged: gamestream.isometric.events.onChangedPlayerAlive);
  final totalGrenades = Watch(0);
  final previousPosition = IsometricPosition();
  final storeItems = Watch(<int>[]);
  final items = <int, int> {};
  final items_reads = Watch(0);

  final energy = Watch(0);
  final energyMax = Watch(0);
  var energyPercentage = 0.0;

  var position = IsometricPosition();
  var runningToTarget = false;
  var targetCategory = TargetCategory.Nothing;
  var targetPosition = IsometricPosition();
  var aimTargetCategory = TargetCategory.Nothing;
  var aimTargetType = 0;
  var aimTargetName = "";
  var aimTargetQuantity = 0;
  var aimTargetPosition = IsometricPosition();
  final weaponCooldown = Watch(1.0);
  final interpolating = Watch(true);
  final target = IsometricPosition();
  final questAdded = Watch(false);
  late var gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  var mouseAngle = 0.0;
  var npcTalk = Watch("");
  var npcTalkOptions = Watch<List<String>>([]);
  final abilityTarget = IsometricPosition();
  var aimTargetChanged = Watch(0);
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetAllie = Watch<bool>(false);
  final mouseTargetHealth = Watch(0.0);
  late final message = Watch("", onChanged: gamestream.isometric.events.onChangedPlayerMessage);
  var messageTimer = 0;

  var indexZ = 0;
  var indexRow = 0;
  var indexColumn = 0;
  var nodeIndex = 0;

  double get x => position.x;
  double get y => position.y;
  double get z => position.z;
  int get areaNodeIndex => (indexRow * gamestream.isometric.nodes.totalColumns) + indexColumn;

  double get renderX => GameIsometricRenderer.convertV3ToRenderX(position);
  double get renderY => GameIsometricRenderer.convertV3ToRenderY(position);
  double get positionScreenX => engine.worldToScreenX(gamestream.isometric.player.position.renderX);
  double get positionScreenY => engine.worldToScreenY(gamestream.isometric.player.position.renderY);
  bool get interactModeTrading => gamestream.isometric.serverState.interactMode.value == InteractMode.Trading;
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

  void Refresh_Items(){
    items_reads.value++;
  }

  Watch<int> getItemGroupWatch(ItemGroup itemGroup){
    switch (itemGroup) {
      case ItemGroup.Primary_Weapon:
        return weaponPrimary;
      case ItemGroup.Secondary_Weapon:
        return weaponSecondary;
      case ItemGroup.Tertiary_Weapon:
        return weaponTertiary;
      case ItemGroup.Head_Type:
        return head;
      case ItemGroup.Body_Type:
        return body;
      case ItemGroup.Legs_Type:
        return legs;
      default:
        throw Exception('gamestream.isometricEngine.player.getItemGroupWatch($itemGroup)');
    }
  }

  Watch<int> getItemTypeWatch(int itemType){
    if (ItemType.isTypeWeapon(itemType)) return weapon;
    if (ItemType.isTypeHead(itemType)) return head;
    if (ItemType.isTypeBody(itemType)) return body;
    if (ItemType.isTypeLegs(itemType)) return legs;
    throw Exception(
        "gamestream.isometricEngine.player.getItemTypeWatch(${ItemType.getName(itemType)})"
    );
  }
}

typedef ItemTypeEntry = MapEntry<int, int>;