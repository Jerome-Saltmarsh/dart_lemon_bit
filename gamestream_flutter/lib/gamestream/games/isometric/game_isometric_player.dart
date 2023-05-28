import 'package:gamestream_flutter/library.dart';

import 'game_isometric_renderer.dart';

class GameIsometricPlayer {
  final id = Watch(0);
  final perkType = Watch(PerkType.None);
  final powerType = Watch(PowerType.None);
  final powerReady = Watch(true);
  final weapon = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);
  final weaponPrimary = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);
  final weaponSecondary = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);
  final weaponTertiary = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);
  final respawnTimer = Watch(0, onChanged: GameEvents.onChangedPlayerRespawnTimer);

  final attributeHealth = Watch(0);
  final attributeMagic = Watch(0);
  final attributeDamage = Watch(0);

  final body = Watch(0);
  final head = Watch(0);
  final legs = Watch(0);
  final active = Watch(false, onChanged: GameEvents.onChangedPlayerActive);
  final alive = Watch(true, onChanged: GameEvents.onChangedPlayerAlive);
  final totalGrenades = Watch(0);
  final previousPosition = Vector3();
  final storeItems = Watch(<int>[]);
  final items = <int, int> {};
  final items_reads = Watch(0);

  final energy = Watch(0);
  final energyMax = Watch(0);
  var energyPercentage = 0.0;

  var position = Vector3();
  var runningToTarget = false;
  var targetCategory = TargetCategory.Nothing;
  var targetPosition = Vector3();
  var aimTargetCategory = TargetCategory.Nothing;
  var aimTargetType = 0;
  var aimTargetName = "";
  var aimTargetQuantity = 0;
  var aimTargetPosition = Vector3();
  final weaponCooldown = Watch(1.0);
  final interpolating = Watch(true);
  final target = Vector3();
  final questAdded = Watch(false);
  late var gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  var mouseAngle = 0.0;
  var npcTalk = Watch("");
  var npcTalkOptions = Watch<List<String>>([]);
  final abilityTarget = Vector3();
  var aimTargetChanged = Watch(0);
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetAllie = Watch<bool>(false);
  final mouseTargetHealth = Watch(0.0);
  final message = Watch("", onChanged: GameEvents.onChangedPlayerMessage);
  var messageTimer = 0;

  var indexZ = 0;
  var indexRow = 0;
  var indexColumn = 0;
  var nodeIndex = 0;

  double get x => position.x;
  double get y => position.y;
  double get z => position.z;
  int get areaNodeIndex => (indexRow * gamestream.games.isometric.nodes.totalColumns) + indexColumn;

  double get renderX => GameIsometricRenderer.convertV3ToRenderX(position);
  double get renderY => GameIsometricRenderer.convertV3ToRenderY(position);
  double get positionScreenX => engine.worldToScreenX(gamestream.games.isometric.player.position.renderX);
  double get positionScreenY => engine.worldToScreenY(gamestream.games.isometric.player.position.renderY);
  bool get interactModeTrading => gamestream.games.isometric.serverState.interactMode.value == InteractMode.Trading;
  bool get dead => !alive.value;
  bool get inBounds => gamestream.games.isometric.nodes.inBoundsVector3(position);


  bool isCharacter(Character character){
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
    final index = position.nodeIndex + gamestream.games.isometric.nodes.area;
    while (index < gamestream.games.isometric.nodes.total){
      if (NodeType.isRainOrEmpty(gamestream.games.isometric.nodes.nodeTypes[index]))  continue;
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
        throw Exception('gamestream.games.isometric.player.getItemGroupWatch($itemGroup)');
    }
  }

  Watch<int> getItemTypeWatch(int itemType){
    if (ItemType.isTypeWeapon(itemType)) return weapon;
    if (ItemType.isTypeHead(itemType)) return head;
    if (ItemType.isTypeBody(itemType)) return body;
    if (ItemType.isTypeLegs(itemType)) return legs;
    throw Exception(
        "gamestream.games.isometric.player.getItemTypeWatch(${ItemType.getName(itemType)})"
    );
  }
}

typedef ItemTypeEntry = MapEntry<int, int>;