import 'package:gamestream_flutter/library.dart';

class GamePlayer {
  static final id = Watch(0);
  static final powerType = Watch(PowerType.None);
  static final powerReady = Watch(true);
  static final weapon = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);
  static final weaponPrimary = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);
  static final weaponSecondary = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);
  static final weaponTertiary = Watch(0, onChanged: GameEvents.onChangedPlayerWeapon);

  static final body = Watch(0);
  static final head = Watch(0);
  static final legs = Watch(0);
  static final alive = Watch(true);
  static final totalGrenades = Watch(0);
  static final previousPosition = Vector3();
  static final storeItems = Watch(<int>[]);
  static final items = <int, int> {};
  static final items_reads = Watch(0);

  static final energy = Watch(0);
  static final energyMax = Watch(0);
  static var energyPercentage = 0.0;

  static var position = Vector3();
  static var runningToTarget = false;
  static var targetCategory = TargetCategory.Nothing;
  static var targetPosition = Vector3();
  static var aimTargetCategory = TargetCategory.Nothing;
  static var aimTargetType = 0;
  static var aimTargetName = "";
  static var aimTargetQuantity = 0;
  static var aimTargetPosition = Vector3();
  static final weaponCooldown = Watch(1.0);
  static final interpolating = Watch(true);
  static final action = Watch(PlayerAction.None);
  static final actionItemType = Watch(ItemType.Empty);
  static final actionCost = Watch(0);
  static final target = Vector3();
  static final questAdded = Watch(false);
  static var gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  static var mouseAngle = 0.0;
  static var npcTalk = Watch("");
  static var npcTalkOptions = Watch<List<String>>([]);
  static final abilityTarget = Vector3();
  static var aimTargetChanged = Watch(0);
  static final mouseTargetName = Watch<String?>(null);
  static final mouseTargetAllie = Watch<bool>(false);
  static final mouseTargetHealth = Watch(0.0);
  static final message = Watch("", onChanged: GameEvents.onChangedPlayerMessage);
  static var messageTimer = 0;

  static var indexZ = 0;
  static var indexRow = 0;
  static var indexColumn = 0;
  static var nodeIndex = 0;

  static int get areaNodeIndex => (indexRow * GameNodes.totalColumns) + indexColumn;

  static double get renderX => GameConvert.convertV3ToRenderX(position);
  static double get renderY => GameConvert.convertV3ToRenderY(position);
  static double get positionScreenX => Engine.worldToScreenX(position.renderX);
  static double get positionScreenY => Engine.worldToScreenY(position.renderX);
  static bool get interactModeTrading => ServerState.interactMode.value == InteractMode.Trading;
  static bool get dead => !alive.value;
  static bool get inBounds => GameQueries.inBoundsVector3(position);


  static bool isCharacter(Character character){
    return position.x == character.x && position.y == character.y && position.z == character.z;
  }

  static void onChangedGameDialog(GameDialog? value){
    GameAudio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }

  static bool isInsideBuilding(){
     if (!inBounds) return false;
     final index = position.nodeIndex + GameNodes.area;
     while (index < GameNodes.total){
       if (NodeType.isRainOrEmpty(GameNodes.nodeTypes[index]))  continue;
       return true;
     }
     return false;
  }

  static void Refresh_Items(){
    items_reads.value++;
  }

  static Watch<int> getItemGroupWatch(ItemGroup itemGroup){
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
        throw Exception('GamePlayer.getItemGroupWatch($itemGroup)');
    }
  }

  static List<int> getItemTypesByItemGroup(ItemGroup itemGroup) =>
      GameOptions.ItemTypes.value
          .where((itemType) => ItemType.getItemGroup(itemType) == itemGroup)
          .toList();

  static Watch<int> getItemTypeWatch(int itemType){
    if (ItemType.isTypeWeapon(itemType)) return weapon;
    if (ItemType.isTypeHead(itemType)) return head;
    if (ItemType.isTypeBody(itemType)) return body;
    if (ItemType.isTypeLegs(itemType)) return legs;
    throw Exception(
        "GamePlayer.getItemTypeWatch(${ItemType.getName(itemType)})"
    );
  }
}

typedef ItemTypeEntry = MapEntry<int, int>;