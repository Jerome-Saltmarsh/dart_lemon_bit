
import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_server/common/src/api_player.dart';
import 'package:bleed_server/common/src/api_players.dart';
import 'package:bleed_server/common/src/compile_util.dart';
import 'package:bleed_server/common/src/direction.dart';
import 'package:bleed_server/common/src/enums/input_mode.dart';
import 'package:bleed_server/common/src/enums/item_group.dart';
import 'package:bleed_server/common/src/enums/perk_type.dart';
import 'package:bleed_server/common/src/environment_response.dart';
import 'package:bleed_server/common/src/game_error.dart';
import 'package:bleed_server/common/src/game_event_type.dart';
import 'package:bleed_server/common/src/interact_mode.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/common/src/node_size.dart';
import 'package:bleed_server/common/src/player_event.dart';
import 'package:bleed_server/common/src/power_type.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:bleed_server/common/src/target_category.dart';
import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/games/game_editor.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/utilities/generate_random_name.dart';
import 'package:bleed_server/src/utilities/system.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import 'isometric_ai.dart';
import 'isometric_collider.dart';
import 'isometric_game.dart';
import 'isometric_character.dart';
import 'isometric_gameobject.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';
import 'isometric_scene.dart';
import 'isometric_scene_writer.dart';
import 'isometric_settings.dart';
import 'isometric_side.dart';

class IsometricPlayer extends IsometricCharacterTemplate with ByteWriter implements Player {
  /// CONSTANTS
  final mouse = Vector2(0, 0);
  var inputMode = InputMode.Keyboard;
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var framesSinceClientRequest = 0;
  static const inventory_size = 6 * 5;

  /// Variables
  late IsometricGame game;
  final runTarget = IsometricPosition();
  late Function sendBufferToClient;
  IsometricGameObject? editorSelectedGameObject;
  /// Frames per energy rejuvenation
  var energyGainRate = 16;
  var debug = false;
  var textDuration = 0;
  var maxEnergy = 10;
  var text = "";
  var name = generateRandomName();
  var sceneDownloaded = false;
  var initialized = false;
  var id = 0;

  var inventoryDirty = false;

  var belt1_itemType = ItemType.Empty; // 1
  var belt2_itemType = ItemType.Empty; // 2
  var belt3_itemType = ItemType.Empty; // 3
  var belt4_itemType = ItemType.Empty; // 4
  var belt5_itemType = ItemType.Empty; // Q
  var belt6_itemType = ItemType.Empty; // E

  var belt1_quantity = 0; // 1
  var belt2_quantity = 0; // 2
  var belt3_quantity = 0; // 3
  var belt4_quantity = 0; // 4
  var belt5_quantity = 0; // Q
  var belt6_quantity = 0; // E

  var weaponPrimary = ItemType.Empty;
  var weaponSecondary = ItemType.Empty;
  var weaponTertiary = ItemType.Empty;
  var powerCooldown = 0;

  var _credits = 0;
  var _experience = 0;
  var _level = 1;
  var _attributes = 0;
  var _energy = 10;
  var _equippedWeaponIndex = 0;
  var _powerType = PowerType.None;
  var _respawnTimer = 0;

  int get respawnTimer => _respawnTimer;

  int get attributes => _attributes;

  set attributes(int value) {
    _attributes = max(value, 0);
    writeApiPlayerAttributes();
  }

  set respawnTimer(int value){
     if (_respawnTimer == value) return;
     _respawnTimer = value;
     writeApiPlayerRespawnTimer();
  }

  var _perkType = PerkType.None;

  int get perkType => _perkType;

  set perkType(int value) {
     assert (PerkType.values.contains(value));
     if (!PerkType.values.contains(value)) return;
     if (_perkType == value) return;
     _perkType = value;
     game.customOnPlayerPerkTypeChanged(this);
     writeApiPlayerPerkType();
  }

  /// Warning - do not reference
  // GameIsometric game;
  IsometricCollider? _aimTarget; // the currently highlighted character
  var aimTargetWeaponSide = IsometricSide.Left;
  Account? account;
  final inventory = Uint16List(inventory_size);
  final inventoryQuantity = Uint16List(inventory_size);
  final inventoryUpgrades = Uint16List(inventory_size);
  var storeItems = <int>[];
  var options = <String, Function> {};
  var _interactMode = InteractMode.Inventory;
  var inventoryOpen = true;
  var nextEnergyGain = 0;

  /// the key is the item_type and the value is its level
  final item_level = <int, int> {};
  final item_quantity = <int, int> {};

  var actionItemId = -1;

  int get powerType => _powerType;

  set powerType(int value) {
     if (_powerType == value) return;
     assert (PowerType.values.contains(value));
     if (!PowerType.values.contains(value)) return;
     _powerType = value;
     writePlayerPower();
  }

  ItemGroup get weaponTypeItemGroup => ItemType.getItemGroup(weaponType);
  int get grenades => getItemQuantity(ItemType.Weapon_Thrown_Grenade);

  bool get aimTargetWithinInteractRadius => aimTarget != null
      ? getDistance3(aimTarget!) < IsometricSettings.Interact_Radius
      : false;

  bool get weaponPrimaryEquipped => weaponType == weaponPrimary;
  bool get weaponSecondaryEquipped => weaponType == weaponSecondary;

  /// CONSTRUCTOR
  IsometricPlayer({
    required this.game,
  }) : super(
    x: 0,
    y: 0,
    z: 0,
    health: 10,
    team: 0,
    weaponType: 0,
    damage: 1,
  ){
    writeGameType();
    writePlayerTeam();
    id = game.playerId++;
    maxEnergy = energy;
    _energy = maxEnergy;
  }

  /// GETTERS
  ///
  IsometricCollider? get aimTarget => _aimTarget;
  int get score => _credits;
  int get level => _level;
  int get equippedWeaponIndex => _equippedWeaponIndex;
  int get lookDirection => Direction.fromRadian(lookRadian);
  int get experience => _experience;
  int get energy => _energy;
  int get experienceRequiredForNextLevel => game.getExperienceForLevel(level + 1);
  bool get weaponIsEquipped => _equippedWeaponIndex != -1;

  double get mouseGridX => (mouse.x + mouse.y) + z;
  double get mouseGridY => (mouse.y - mouse.x) + z;
  int get interactMode => _interactMode;
  /// in radians
  double get mouseAngle => getAngleBetween(mouseGridX  + Character_Gun_Height, mouseGridY + Character_Gun_Height, x, y);
  IsometricScene get scene => game.scene;
  double get magicPercentage {
    if (_energy == 0) return 0;
    if (maxEnergy == 0) return 0;
    return _energy / maxEnergy;
  }

  double get experiencePercentage {
    if (experienceRequiredForNextLevel <= 0) return 1.0;
    return _experience / experienceRequiredForNextLevel;
  }

  set equippedWeaponIndex(int index){
    if (_equippedWeaponIndex == index) return;
    if (index == -1){
      unequipWeapon();
      return;
    }
    assert (isValidInventoryIndex(index));

    final itemTypeAtIndex = inventoryGetItemType(index);

    if (ItemType.isTypeWeapon(itemTypeAtIndex)){
      _equippedWeaponIndex = index;
      weaponType = itemTypeAtIndex;
      inventoryDirty = true;
      assignWeaponStateChanging();
      game.dispatchV3(GameEventType.Character_Changing, this);
      refreshDamage();
      return;
    }

    unequipWeapon();
    return;
  }

  set level(int value){
    assert (value >= 1);
    if (_level == value) return;
    _level = value;
    writePlayerLevel();
  }

  set score(int value) {
    if (_credits == value) return;
    _credits = max(value, 0);
    // todo
    // if (game.engine.highScore < value) {
    //   game.engine.highScore = value;
    // }
    writePlayerCredits();
    game.customOnPlayerCreditsChanged(this);
  }

  set aimTarget(IsometricCollider? collider) {
    if (_aimTarget == collider) return;
    if (collider == this) return;
    _aimTarget = collider;
    writePlayerAimTargetCategory();
    writePlayerAimTargetType();
    writePlayerAimTargetPosition();
    writePlayerAimTargetName();
    writePlayerAimTargetQuantity();
    game.customOnPlayerAimTargetChanged(this, collider);
  }

  set energy(int value) {
    final clampedValue = clamp(value, 0, maxEnergy);
    if (_energy == clampedValue) return;
    _energy = clampedValue;
    writePlayerEnergy();
  }

  /// METHODS
  void refreshDamage() {
    damage = game.getPlayerWeaponDamage(this);
  }

  void unequipWeapon(){
    _equippedWeaponIndex = -1;
    weaponType = ItemType.Empty;
    inventoryDirty = true;
    game.setCharacterStateChanging(this);
    refreshDamage();
  }

  set interactMode(int value){
    if (_interactMode == value) return;
    _interactMode = value;
    writePlayerInteractMode();
  }

  int? getEmptyInventoryIndex(){
    for (var i = 0; i < inventory.length; i++){
      if (inventory[i] != ItemType.Empty) continue;
      return i;
    }
    return null;
  }

  int? getEmptyBeltIndex(){
    if (belt1_itemType == ItemType.Empty) return ItemType.Belt_1;
    if (belt2_itemType == ItemType.Empty) return ItemType.Belt_2;
    if (belt3_itemType == ItemType.Empty) return ItemType.Belt_3;
    if (belt4_itemType == ItemType.Empty) return ItemType.Belt_4;
    if (belt5_itemType == ItemType.Empty) return ItemType.Belt_5;
    if (belt6_itemType == ItemType.Empty) return ItemType.Belt_6;
    return null;
  }

  set experience(int value) {
    if (_experience == value) return;
    assert (value >= 0);
    _experience = value;
    while (value >= experienceRequiredForNextLevel) {
      value -= experienceRequiredForNextLevel;
      level++;
      game.customOnPlayerLevelGained(this);
      writePlayerEvent(PlayerEvent.Level_Increased);
    }
    writePlayerExperiencePercentage();
  }

  void endInteraction(){
    if (interactMode == InteractMode.None) return;
    if (storeItems.isNotEmpty) {
      storeItems = [];
      writeStoreItems();
    }
    if (options.isNotEmpty) {
      options.clear();
    }
    if (inventoryOpen) {
      interactMode = InteractMode.Inventory;
    } else {
      interactMode = InteractMode.None;
    }
  }

  void interact({required String message, Map<String, Function>? responses}){
    writeNpcTalk(text: message, options: responses);
  }

  bool isValidInventoryIndex(int? index) =>
      index != null &&
      index >= 0 &&
      (
          ItemType.isTypeEquipped(index) ||
          ItemType.isIndexBelt(index) ||
          index < inventory.length
      );


  void setStoreItems(List<int> values){
    if (values.isNotEmpty){
      interactMode = InteractMode.Trading;
    }
    this.storeItems = values;
    writeStoreItems();
  }

  void runToMouse(){
    setRunTarget(mouseGridX - 16, mouseGridY - 16);
  }

  void setRunTarget(double x, double y){
    runTarget.x = x;
    runTarget.y = y;
    runTarget.z = z;
    game.setCharacterTarget(this, runTarget);
  }

  void inventoryDrop(int index) {
    assert (isValidInventoryIndex(index));
    dropItemType(itemType: inventoryGetItemType(index), quantity: inventoryGetItemQuantity(index));
    inventorySetEmptyAtIndex(index);
  }

  void dropItemType({required int itemType, required int quantity}){
    if (itemType == ItemType.Empty) return;
    game.spawnGameObjectItemAtPosition(
      position: this,
      type: itemType,
      quantity: quantity,
    );
    writePlayerEvent(PlayerEvent.Item_Dropped);
  }

  int inventoryGetItemType(int index){
    if (index == -1){
      return ItemType.Empty;
    }
    if (index == ItemType.Equipped_Weapon)
      return weaponType;
    if (index == ItemType.Equipped_Body)
      return bodyType;
    if (index == ItemType.Equipped_Head)
      return headType;
    if (index == ItemType.Equipped_Legs)
      return legsType;

    if (index == ItemType.Belt_1)
      return belt1_itemType;
    if (index == ItemType.Belt_2)
      return belt2_itemType;
    if (index == ItemType.Belt_3)
      return belt3_itemType;
    if (index == ItemType.Belt_4)
      return belt4_itemType;
    if (index == ItemType.Belt_5)
      return belt5_itemType;
    if (index == ItemType.Belt_6)
      return belt6_itemType;

    assert(index < inventory.length);
    return inventory[index];
  }

  int inventoryGetTotalQuantityOfItemType(int itemType){
     var total = 0;
     for (var i = 0; i < inventory.length; i++){
        if (inventory[i] != itemType) continue;
        total += inventoryQuantity[i];
     }
     if (belt1_itemType == itemType){
        total += belt1_quantity;
     }
     if (belt2_itemType == itemType){
       total += belt2_quantity;
     }
     if (belt3_itemType == itemType){
       total += belt3_quantity;
     }
     if (belt4_itemType == itemType){
       total += belt4_quantity;
     }
     if (belt5_itemType == itemType){
       total += belt5_quantity;
     }
     if (belt6_itemType == itemType){
       total += belt6_quantity;
     }
     return total;
  }

  int inventoryGetItemQuantity(int index){
    assert (index >= 0);
    assert (isValidInventoryIndex(index));

    final itemType = inventoryGetItemType(index);
    if (itemType == ItemType.Empty) return 0;
    // if (ItemType.doesConsumeOnUse(itemType)) return 1;

    // if (index == ItemType.Equipped_Weapon)
    //   return 1;
    if (index == ItemType.Equipped_Body)
      return 1;
    if (index == ItemType.Equipped_Head)
      return 1;
    if (index == ItemType.Equipped_Legs)
      return 1;

    if (index == ItemType.Belt_1)
      return belt1_quantity;
    if (index == ItemType.Belt_2)
      return belt2_quantity;
    if (index == ItemType.Belt_3)
      return belt3_quantity;
    if (index == ItemType.Belt_4)
      return belt4_quantity;
    if (index == ItemType.Belt_5)
      return belt5_quantity;
    if (index == ItemType.Belt_6)
      return belt6_quantity;

    assert(index < inventoryQuantity.length);
    return inventoryQuantity[index];
  }

  void writeErrorInvalidInventoryIndex(int index){
     writeGameError(GameError.Invalid_Inventory_Index);
  }

  void writeInfo(String info){
    writeByte(ServerResponse.Info);
    writeString(info);
  }

  void inventoryDeposit(int index){
    if (!isValidInventoryIndex(index)){
      writePlayerEventInvalidRequest();
      return;
    }
    if (index < inventory.length) return;
    final emptyInventoryIndex = getEmptyInventoryIndex();
    if (emptyInventoryIndex == null) {
      writePlayerEventInventoryFull();
      return;
    }
    inventorySwapIndexes(index, emptyInventoryIndex);
  }

  void inventoryBuy(int index){
    if (interactMode != InteractMode.Trading) {
      writeGameError(GameError.Cannot_Purchase_At_The_Moment);
      return;
    }
    if (index < 0) {
      writeErrorInvalidInventoryIndex(index);
      return;
    }
    if (index >= storeItems.length) {
      writeErrorInvalidInventoryIndex(index);
      return;
    }
    final itemType = storeItems[index];
    if (itemType == ItemType.Empty) {
      writeGameError(GameError.Invalid_Purchase_index);
      return;
    }

    inventoryDirty = true;
    final emptyInventoryIndex = getEmptyInventoryIndex();
    if (emptyInventoryIndex == null) {
      game.spawnGameObjectItemAtPosition(position: this, type: itemType, quantity: 1);
      writePlayerEvent(PlayerEvent.Inventory_Full);
      return;
    }
    inventory[emptyInventoryIndex] = itemType;

    var quantity = 1;
    if (ItemType.isTypeWeapon(itemType)){
      quantity = ItemType.getMaxQuantity(itemType);
    }
    inventoryQuantity[emptyInventoryIndex] = quantity;
  }


  void inventoryReduceItemTypeQuantity({required int itemType, required int reduction}){
    final quantityInPossession = inventoryGetTotalQuantityOfItemType(itemType);
    assert (quantityInPossession >= reduction);
    var reductionRemaining = reduction;
    inventoryDirty = true;

    for (var i = 0; i < inventory.length; i++) {
      if (inventory[i] != itemType) continue;
      final quantity = inventoryQuantity[i];

      if (quantity >= reductionRemaining) {
        inventoryQuantity[i] -= reductionRemaining;
        if (inventoryQuantity[i] == 0) {
          inventorySetEmptyAtIndex(i);
        }
        break;
      }
      reductionRemaining -= quantity;
      inventorySetEmptyAtIndex(i);
    }

    if (reductionRemaining == 0) return;

    for (final beltIndex in ItemType.Belt_Indexes){
       if (inventoryGetItemType(beltIndex) != itemType) continue;
       final beltQuantity = inventoryGetItemQuantity(beltIndex);
       if (beltQuantity >= reductionRemaining) {
         inventorySetQuantityAtIndex(quantity: beltQuantity - reductionRemaining, index: beltIndex);
         return;
       }
       inventorySetEmptyAtIndex(beltIndex);
    }
  }

  static bool removeOnEmpty(int itemType) =>
      itemType == ItemType.Weapon_Thrown_Grenade ||
      ItemType.isTypeConsumable(itemType);

  void inventorySetQuantityAtIndex({required int quantity, required int index}){
    assert (isValidInventoryIndex(index));
    final itemType = inventoryGetItemType(index);

    if (quantity == 0) {
      if (ItemType.isTypeResource(itemType)){
        inventorySetEmptyAtIndex(index);
      }
    }
    if (index < inventory.length) {
      inventoryQuantity[index] = quantity;
      return;
    }
    if (index == ItemType.Belt_1){
      belt1_quantity = quantity;
      if (belt1_quantity == 0 && removeOnEmpty(itemType)){
        inventorySetEmptyAtIndex(ItemType.Belt_1);
      }
      return;
    }
    if (index == ItemType.Belt_2){
      belt2_quantity = quantity;
      if (belt2_quantity == 0 && removeOnEmpty(itemType)){
        inventorySetEmptyAtIndex(ItemType.Belt_2);
      }
      return;
    }
    if (index == ItemType.Belt_3){
      belt3_quantity = quantity;
      if (belt3_quantity == 0 && removeOnEmpty(itemType)){
        inventorySetEmptyAtIndex(ItemType.Belt_3);
      }
      return;
    }
    if (index == ItemType.Belt_4){
      belt4_quantity = quantity;
      if (belt4_quantity == 0 && removeOnEmpty(itemType)){
        inventorySetEmptyAtIndex(ItemType.Belt_4);
      }
      return;
    }
    if (index == ItemType.Belt_5){
      belt5_quantity = quantity;
      if (belt5_quantity == 0 && removeOnEmpty(itemType)){
        inventorySetEmptyAtIndex(ItemType.Belt_5);
      }
      return;
    }
    if (index == ItemType.Belt_6){
      belt6_quantity = quantity;
      if (belt6_quantity == 0 && removeOnEmpty(itemType)){
        inventorySetEmptyAtIndex(ItemType.Belt_6);
      }
      return;
    }
  }

  void inventorySell(int index) {
    if (interactMode != InteractMode.Trading) {
      writePlayerEventInvalidRequest();
      return;
    }
    if (!isValidInventoryIndex(index)) {
      writePlayerEventInvalidRequest();
      return;
    }
    final itemType = inventoryGetItemType(index);
    if (itemType == ItemType.Empty) {
      writePlayerEventInvalidRequest();
      return;
    }
    inventorySetEmptyAtIndex(index);
    writePlayerEvent(PlayerEvent.Item_Sold);
  }

  void inventorySetEmptyAtIndex(int index) =>
    inventorySet(index: index, itemType: ItemType.Empty, itemQuantity: 0);

  void inventorySet({
    required int index,
    required int itemType,
    required int itemQuantity,
  }){
    assert (isValidInventoryIndex(index));
    assert (itemTypeCanBeAssignedToIndex(itemType: itemType, index: index));
    assert (itemType != ItemType.Empty || itemQuantity == 0);

    final maxQuantity = ItemType.getMaxQuantity(itemType);
    itemQuantity = clamp(itemQuantity, 1, maxQuantity);

    if (index == equippedWeaponIndex) {
       if (ItemType.isTypeWeapon(itemType)) {
         weaponType = itemType;
         inventoryDirty = true;
         game.setCharacterStateChanging(this);
       }
       equippedWeaponIndex = -1;
    }

    if (index == ItemType.Equipped_Weapon) {
      if (weaponType == itemType) return;
      weaponType = itemType;
      inventoryDirty = true;
      game.setCharacterStateChanging(this);
    } else
    if (index == ItemType.Equipped_Body) {
      bodyType = itemType;
      inventoryDirty = true;
      game.setCharacterStateChanging(this);
    } else
    if (index == ItemType.Equipped_Head) {
      headType = itemType;
      inventoryDirty = true;
      game.setCharacterStateChanging(this);
    } else
    if (index == ItemType.Equipped_Legs) {
      legsType = itemType;
      inventoryDirty = true;
      game.setCharacterStateChanging(this);
    } else
    if (index == ItemType.Belt_1){
      belt1_itemType = itemType;
      belt1_quantity = itemQuantity;
      inventoryDirty = true;
    } else
    if (index == ItemType.Belt_2){
      belt2_itemType = itemType;
      belt2_quantity = itemQuantity;
      inventoryDirty = true;
    } else
    if (index == ItemType.Belt_3){
      belt3_itemType = itemType;
      belt3_quantity = itemQuantity;
      inventoryDirty = true;
    } else
    if (index == ItemType.Belt_4){
      if (belt4_itemType == itemType) return;
      belt4_itemType = itemType;
      belt4_quantity = itemQuantity;
      inventoryDirty = true;
    } else
    if (index == ItemType.Belt_5){
      belt5_itemType = itemType;
      belt5_quantity = itemQuantity;
      inventoryDirty = true;
    } else
    if (index == ItemType.Belt_6){
      belt6_itemType = itemType;
      belt6_quantity = itemQuantity;
      inventoryDirty = true;
    } else
    if (index < inventory.length){
      inventory[index] = itemType;
      inventoryQuantity[index] = itemQuantity;
      inventoryDirty = true;
    }
    refreshDamage();
  }

  void inventorySwapIndexes(int indexA, int indexB) {
     if (indexA == indexB) return;
     assert (isValidInventoryIndex(indexA));
     assert (isValidInventoryIndex(indexB));
     final indexAType = inventoryGetItemType(indexA);
     final indexBType = inventoryGetItemType(indexB);
     final indexAQuantity = inventoryGetItemQuantity(indexA);
     final indexBQuantity = inventoryGetItemQuantity(indexB);

     final weaponsSwapped = indexA == equippedWeaponIndex || indexB == equippedWeaponIndex;
     final currentEquippedWeaponIndex = equippedWeaponIndex;

     if (indexAType == indexBType){
       if (ItemType.isTypeResource(indexAType)){
          final total = indexAQuantity + indexBQuantity;
          final totalMax = ItemType.getMaxQuantity(indexAType);
          if (total < totalMax){
            inventorySetEmptyAtIndex(indexA);
            inventorySetQuantityAtIndex(quantity: total, index: indexB);
          } else {
            inventorySetQuantityAtIndex(quantity: total - totalMax, index: indexA);
            inventorySetQuantityAtIndex(quantity: totalMax, index: indexB);
          }
          inventoryDirty = true;
          assignWeaponStateChanging();
          game.dispatchV3(GameEventType.Character_Changing, this);
          return;
       }
     }

     if (itemTypeCanBeAssignedToIndex(itemType: indexAType, index: indexB)){
       inventorySet(index: indexB, itemType: indexAType, itemQuantity: indexAQuantity);
     } else {
       inventoryAdd(itemType: indexAType, itemQuantity: indexAQuantity);
       inventorySetEmptyAtIndex(indexB);
     }

     if (itemTypeCanBeAssignedToIndex(itemType: indexBType, index: indexA)){
       inventorySet(index: indexA, itemType: indexBType, itemQuantity: indexBQuantity);
     } else {
       inventoryAdd(itemType: indexBType, itemQuantity: indexBQuantity);
       inventorySetEmptyAtIndex(indexA);
     }

     if (weaponsSwapped && ItemType.isTypeWeapon(indexAType) && ItemType.isTypeWeapon(indexBType)) {
        equippedWeaponIndex = currentEquippedWeaponIndex;
     }

     assignWeaponStateChanging();
     game.dispatchV3(GameEventType.Character_Changing, this);
  }

  bool itemTypeCanBeAssignedToIndex({
    required int itemType,
    required int index,
  }) {
    if (!isValidInventoryIndex(index)) return false;
    if (itemType == ItemType.Empty) return true;
    if (index < inventory.length) return true;
    if (ItemType.isIndexBelt(index)) return true;

    if (index == ItemType.Equipped_Head){
      return ItemType.isTypeHead(itemType);
    }
    if (index == ItemType.Equipped_Body){
      return ItemType.isTypeBody(itemType);
    }
    if (index == ItemType.Equipped_Legs){
      return ItemType.isTypeLegs(itemType);
    }
    if (index == ItemType.Equipped_Weapon){
      return ItemType.isTypeWeapon(itemType);
    }
    return false;
  }

  void inventoryAddMax({required int itemType}){
    inventoryAdd(itemType: itemType, itemQuantity: ItemType.getMaxQuantity(itemType));
  }

  void inventoryAdd({required int itemType, int itemQuantity = 1}) {
      assert (itemQuantity > 0);
      final availableIndex = getEmptyInventoryIndex();
      if (availableIndex != null) {
        inventorySet(
            index: availableIndex,
            itemType: itemType,
            itemQuantity: itemQuantity,
        );
        return;
      }
      dropItemType(itemType: itemType, quantity: itemQuantity);
  }

  void inventoryUnequip(int index) {
      assert (isValidInventoryIndex(index));

      final emptyInventoryIndex = getEmptyInventoryIndex();
      if (emptyInventoryIndex == null) {
        writePlayerEventInventoryFull();
        return;
      }
      inventorySwapIndexes(index, emptyInventoryIndex);
  }

  void inventoryEquip(int index) {

    if (deadOrBusy) return;

    if (!isValidInventoryIndex(index)) {
      writePlayerEventInvalidRequest();
      return;
    }

    if (ItemType.isTypeEquipped(index)){
      inventoryUnequip(index);
      return;
    }

    final itemType = inventoryGetItemType(index);

    if (ItemType.isTypeWeapon(itemType)){

      if (ItemType.isIndexBelt(index)){
        equippedWeaponIndex = index;
        return;
      }

      // move an item from the inventory to the belt and equip it
      if (index < inventory.length) {

        final emptyBeltIndex = getEmptyBeltIndex();
        if (emptyBeltIndex != null) {
          inventorySwapIndexes(index, emptyBeltIndex);
          equippedWeaponIndex = emptyBeltIndex;
          return;
        }

        // if an item from the bag was selected but all belt slots are already being used
        if (equippedWeaponIndex != -1) {
          inventorySwapIndexes(index, equippedWeaponIndex);
          return;
        }

        // if none of the belts items are weapons simply use the first index
        inventorySwapIndexes(index, ItemType.Belt_1);
        return;
      }
    }
    if (ItemType.isTypeHead(itemType)){
      inventorySwapIndexes(index, ItemType.Equipped_Head);
      return;
    }
    if (ItemType.isTypeBody(itemType)){
      inventorySwapIndexes(index, ItemType.Equipped_Body);
      return;
    }
    if (ItemType.isTypeLegs(itemType)){
      inventorySwapIndexes(index, ItemType.Equipped_Legs);
      return;
    }
    if (ItemType.isTypeConsumable(itemType)) {
       health += ItemType.getHealAmount(itemType);
       energy += ItemType.getReplenishEnergy(itemType);
       writePlayerEventItemTypeConsumed(itemType);
       final quantity = inventoryGetItemQuantity(index);
       final nextQuantity = quantity - 1;
       if (nextQuantity <= 0){
         inventorySetEmptyAtIndex(index);
       } else {
         inventorySetQuantityAtIndex(quantity: nextQuantity, index: index);
       }
       inventoryDirty = true;
       game.setCharacterStateChanging(this);
       // writeGameError('${ItemType.getName(itemType)} consumed');
       return;
    }

    if (index < inventory.length) {
      final emptyBeltIndex = getEmptyBeltIndex();
      if (emptyBeltIndex != null) {
        inventorySwapIndexes(index, emptyBeltIndex);
      } else {
        writeGameError(GameError.Inventory_Equip_Failed_Belt_Full);
      }
      return;
    }

    if (ItemType.isIndexBelt(index)){
      final emptyInventoryIndex = getEmptyInventoryIndex();
      if (emptyInventoryIndex != null) {
        inventorySwapIndexes(index, emptyInventoryIndex);
      } else {
        writeGameError(GameError.Inventory_Equip_Failed_Inventory_Full);
      }
      return;
    }
  }

  void setInventoryDirty(){
    game.setCharacterStateChanging(this);
    inventoryDirty = true;
  }

  void writePlayerPosition(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Position);
    writeIsometricPosition(this);
  }

  void writePlayerHealth(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Health);
    writeUInt16(health);
    writeUInt16(maxHealth); // 2
  }

  void writePlayerDamage() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Damage);
    writeUInt16(damage);
  }

  void writePlayerAlive(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Alive);
    writeBool(alive);
  }

  void writePlayerActive(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Active);
    writeBool(active);
  }

  void writePlayerExperiencePercentage(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Experience_Percentage);
    writePercentage(experiencePercentage);
  }

  void writePlayerLevel(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Level);
    writeUInt16(level);
  }

  void writePlayerAimAngle(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Angle);
    writeAngle(mouseAngle);
  }

  @override
  void writePlayerGame() {
    writePlayerPosition();
    writePlayerWeaponCooldown();
    writePlayerAccuracy();
    writePlayerAimTargetPosition();

    writeProjectiles();
    writePlayerTargetPosition();
    writeCharacters();
    writeEditorGameObjectSelected();

    writeGameTime();

    if (inventoryDirty) {
      inventoryDirty = false;
      writePlayerInventory();
    }

    if (!initialized) {
      initialized = true;
      game.customInitPlayer(this);
      writePlayerPosition();
      writePlayerSpawned();
      writePlayerInventory();
      writePlayerLevel();
      writePlayerExperiencePercentage();
      writePlayerHealth();
      writePlayerAlive();
      writePlayerInteractMode();
      writeHighScore();
    }

    if (!sceneDownloaded){
      downloadScene();
    }
  }

  void writeHighScore(){
    writeByte(ServerResponse.High_Score);
    // writeUInt24(game.engine.highScore);
    writeUInt24(0);
  }

  void writePlayerStats(){
    refreshDamage();
    writePlayerLevel();
    writePlayerExperiencePercentage();
    writePlayerHealth();
    writePlayerEnergy();
    writePlayerAlive();
    writePlayerInteractMode();
  }

  void writePlayerWeaponCooldown() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Weapon_Cooldown);
    writePercentage(weaponDurationPercentage);
  }

  void writePlayerAccuracy(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Accuracy);
    writePercentage(accuracy);
  }

  void writeGameObjects(){
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
      writeGameObject(gameObject);
    }
  }

  void writeCharacters(){
    writeByte(ServerResponse.Characters);
    final characters = game.characters;
    for (final character in characters) {
      if (character.dead) continue;
      if (character.inactive) continue;
      if (character.renderY < screenTop) continue;
      if (character.renderX < screenLeft) continue;
      if (character.renderX > screenRight) continue;
      if (character.renderY > screenBottom) continue;

      if (character.buffInvisible && !IsometricCollider.onSameTeam(this, character)){
        continue;
      }

      writeByte(character.characterType);
      writeCharacterTeamDirectionAndState(character);
      writeVector3(character);
      writeCharacterHealthAndAnimationFrame(character);

      if (character is IsometricCharacterTemplate) {
        writeCharacterUpperBody(character);
      }

      writeByte(character.buffByte);
    }
    writeByte(END);
  }

  void writeCharacterTeamDirectionAndState(IsometricCharacter character){
    writeByte((IsometricCollider.onSameTeam(this, character) ? 100 : 0) + (character.faceDirection * 10) + character.state); // 1
  }

  // todo optimize
  void writeCharacterHealthAndAnimationFrame(IsometricCharacter character) =>
    writeByte((((character.health / character.maxHealth) * 24).toInt() * 10) + character.animationFrame);

  void downloadScene(){
    writeGrid();
    writeGameProperties();
    writeGameType();
    writeWeather();
    writeGameObjects();
    writeGameTime();
    game.customDownloadScene(this);
    writePlayerEvent(PlayerEvent.Scene_Changed);
    sceneDownloaded = true;
  }

  void writePlayerSpawned(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Spawned);
  }

  // void writeAndSendResponse(){
  //   writePlayerGame();
  //   game.customPlayerWrite(this);
  //   writeByte(ServerResponse.End);
  //   sendBufferToClient();
  // }

  void writePlayerTargetPosition(){
    if (target == null) return;
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Target_Position);
    writeIsometricPosition(target!);
  }

  void writePlayerTargetCategory(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Target_Category);
    writeByte(getTargetCategory(target));
  }

  void writePlayerAimTargetPosition(){
    if (aimTarget == null) return;
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Target_Position);
    writeIsometricPosition(aimTarget!);
  }

  void writePlayerAimTargetCategory() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Target_Category);
    writeByte(getTargetCategory(aimTarget));
  }

  void writePlayerAimTargetType() {
    if (aimTarget == null) return;
    if (aimTarget is IsometricGameObject){
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as IsometricGameObject).type);
    }
    if (aimTarget is IsometricCharacter) {
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as IsometricCharacter).characterType);
    }
  }

  void writePlayerAimTargetQuantity() {
    if (aimTarget is IsometricGameObject) {
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Quantity);
      writeUInt16((aimTarget as IsometricGameObject).quantity);
    }
  }

  void writePlayerAimTargetName() {
    if (aimTarget == null) return;

    if (aimTarget is IsometricPlayer) {
      writeApiPlayerAimTargetName((aimTarget as IsometricPlayer).name);
      return;
    }

    if (aimTarget is IsometricAI) {
      writeApiPlayerAimTargetName((aimTarget as IsometricAI).name);
      return;
    }
  }

  void writeApiPlayerAimTargetName(String value) {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Target_Name);
    writeString(value);
  }


  int getTargetCategory(IsometricPosition? value){
    if (value == null) return TargetCategory.Nothing;
    if (value is IsometricGameObject) {
      if (value.interactable) {
        return TargetCategory.Collect;
      }
      return TargetCategory.Nothing;
    }
    if (isAlly(value)) return TargetCategory.Allie;
    if (isEnemy(value)) return TargetCategory.Enemy;
    return TargetCategory.Run;
  }

  bool onScreen(double x, double y){
    const Max_Distance = 800.0;
    if ((this.x - x).abs() > Max_Distance) return false;
    if ((this.y - y).abs() > Max_Distance) return false;
    return true;
  }

  void writeProjectiles(){
    writeByte(ServerResponse.Projectiles);
    final projectiles = game.projectiles;
    var totalActiveProjectiles = 0;
    for (final gameObject in projectiles) {
      if (!gameObject.active) continue;
      totalActiveProjectiles++;
    }
    writeUInt16(totalActiveProjectiles);
    projectiles.forEach(writeProjectile);
  }

  void writeGameEvent({
    required int type,
    required double x,
    required double y,
    required double z,
    required double angle,
  }){
    writeByte(ServerResponse.Game_Event);
    writeByte(type);
    writeDouble(x);
    writeDouble(y);
    writeDouble(z);
    writeDouble(angle * radiansToDegrees);
  }

  void writePlayerEventItemTypeConsumed(int itemType){
    writePlayerEvent(PlayerEvent.Item_Consumed);
    writeUInt16(itemType);
  }

  void writePlayerEventRecipeCrafted() =>
    writePlayerEvent(PlayerEvent.Recipe_Crafted);

  void writePlayerEventInventoryFull() =>
      writePlayerEvent(PlayerEvent.Inventory_Full);

  void writePlayerEventInvalidRequest() =>
      writePlayerEvent(PlayerEvent.Invalid_Request);

  void writePlayerEventItemAcquired(int itemType){
    writePlayerEvent(PlayerEvent.Item_Acquired);
    writeUInt16(itemType);
  }

  void writePlayerEvent(int value){
    writeByte(ServerResponse.Player_Event);
    writeByte(value);
  }

  void writePlayerMoved(){
    writePlayerPosition();
    writePlayerEvent(PlayerEvent.Player_Moved);
  }

  void writeApiPlayerSpawned(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Spawned);
  }

  void writePlayerMessage(String message){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Message);
    writeString(message);
  }

  void writeGameTime(){
    writeByte(ServerResponse.Game_Time);
    writeUInt24(game.time.time);
  }

  void writeProjectile(IsometricProjectile projectile){
    if (!projectile.active) return;
    writePosition(projectile);
    writeDouble(projectile.z);
    writeByte(projectile.type);
    writeAngle(projectile.velocityAngle);
  }

  void writeCharacterUpperBody(IsometricCharacterTemplate character) {
    assert (ItemType.isTypeWeapon(character.weaponType) || character.weaponType == ItemType.Empty);
    assert (ItemType.isTypeLegs(character.legsType) || character.legsType == ItemType.Empty);
    assert (ItemType.isTypeBody(character.bodyType) || character.bodyType == ItemType.Empty);
    assert (ItemType.isTypeHead(character.headType) || character.headType == ItemType.Empty);
    writeUInt16(character.weaponType);
    writeUInt16(character.weaponState); // TODO use byte instead
    writeUInt16(character.bodyType);
    writeUInt16(character.headType);
    writeUInt16(character.legsType);
    writeAngle(character.lookRadian);
    writeByte(character.weaponFrame);
  }

  void writeWeather() {
    final environment = game.environment;
    final underground = false;

    writeByte(ServerResponse.Weather);
    writeByte(environment.rainType);
    writeBool(environment.breezy);
    writeByte(environment.lightningType);
    writeByte(environment.windType);

    writeEnvironmentUnderground(underground);
    writeGameTimeEnabled();
  }

  void writePercentage(double value){
    if (value.isNaN) {
      writeByte(0);
      return;
    }
    if (value > 1.0) writeByte(255);
    writeByte((value * 255).toInt());
  }

  void writePosition(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
  }

  void writeIsometricPosition(IsometricPosition value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeVector3(IsometricPosition value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeGrid() {
    writeByte(ServerResponse.Grid);
    var compiled = scene.compiled;
    if (compiled == null){
      compiled = IsometricSceneWriter.compileScene(scene, gameObjects: false);
      scene.compiled = compiled;
    }
    writeBytes(compiled);
  }

  void writePlayerCredits() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Credits);
    writeUInt16(score);
  }

  void writePlayerItems() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Items);
    writeMap(item_level);
  }

  void writePlayerWeapons() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Weapons);
    writeUInt16(weaponType);
    writeUInt16(weaponPrimary);
    writeUInt16(weaponSecondary);
  }

  void writePlayerInventory() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Inventory);
    writeUInt16(headType);
    writeUInt16(bodyType);
    writeUInt16(legsType);
    writeUInt16(weaponType);
    writeUInt16(belt1_itemType);
    writeUInt16(belt2_itemType);
    writeUInt16(belt3_itemType);
    writeUInt16(belt4_itemType);
    writeUInt16(belt5_itemType);
    writeUInt16(belt6_itemType);
    writeUInt16(belt1_quantity);
    writeUInt16(belt2_quantity);
    writeUInt16(belt3_quantity);
    writeUInt16(belt4_quantity);
    writeUInt16(belt5_quantity);
    writeUInt16(belt6_quantity);
    writeUInt16(equippedWeaponIndex.abs());
    writeUInt16(inventory.length);
    inventory.forEach(writeUInt16);
    inventoryQuantity.forEach(writeUInt16);
  }

  void writePlayerTarget() {
    writeByte(ServerResponse.Player_Target);
    writePosition(target != null ? target! : mouse);

    if (target != null){
      writeDouble(target!.z);
    } else{
      writeDouble(z);
    }
  }

  void writeAngle(double radians){
    writeDouble(radians * radiansToDegrees);
  }

  void writeStoreItems(){
    writeByte(ServerResponse.Store_Items);
    writeUInt16(storeItems.length);
    storeItems.forEach(writeUInt16);
  }

  void writePlayerInteractMode() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Interact_Mode);
    writeByte(interactMode);
  }

  void writeNpcTalk({required String text, Map<String, Function>? options}){
    interactMode = InteractMode.Talking;
    this.options = options ?? {'Goodbye' : endInteraction};
    writeByte(ServerResponse.Npc_Talk);
    writeString(text);
    writeByte(this.options.length);
    for (final option in this.options.keys){
      writeString(option);
    }
  }

  void writeGameProperties() {
    writeByte(ServerResponse.Game_Properties);
    writeBool((game is GameEditor || isLocalMachine));
    writeString(game.scene.name);
    writeBool(game.running);
  }

  void writeEditorGameObjectSelected() {
    final selectedGameObject = editorSelectedGameObject;
    if (selectedGameObject == null) return;
    writeByte(ServerResponse.Editor_GameObject_Selected);
    writeUInt16(selectedGameObject.id);
    writeBool(selectedGameObject.hitable);
    writeBool(selectedGameObject.fixed);
    writeBool(selectedGameObject.collectable);
    writeBool(selectedGameObject.physical);
    writeBool(selectedGameObject.persistable);
    writeBool(selectedGameObject.gravity);
  }

  void writeEnvironmentLightning(int value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Lightning);
    writeByte(value);
  }

  void writeEnvironmentWind(int windType){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Wind);
    writeByte(windType);
  }

  void writeGameTimeEnabled(){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Time_Enabled);
    writeBool(game.time.enabled);
  }

  void writeEnvironmentRain(int rainType){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Rain);
    writeByte(rainType);
  }

  void writeEnvironmentBreeze(bool value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Breeze);
    writeBool(value);
  }

  void writeEnvironmentUnderground(bool underground){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Underground);
    writeBool(underground);
  }

  void writeEnvironmentLightningFlashing(bool value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Lightning_Flashing);
    writeBool(value);
  }

  void writeNode(int index){
    assert (index >= 0);
    assert (index < scene.gridVolume);
    writeByte(ServerResponse.Node);
    writeUInt24(index);
    writeByte(scene.nodeTypes[index]);
    writeByte(scene.nodeOrientations[index]);
  }

  void writePlayerEquippedWeaponAmmunition(){
    // assert (weaponIsEquipped);
    writePlayerInventorySlot(equippedWeaponIndex);
  }

  void writePlayerInventorySlot(int index) {
     assert (isValidInventoryIndex(index));
     writeByte(ServerResponse.Api_Player);
     writeByte(ApiPlayer.Inventory_Slot);
     writeUInt16(index);
     writeUInt16(inventoryGetItemType(index));
     writeUInt16(inventoryGetItemQuantity(index));
  }

  // bool get equippedWeaponUsesAmmunition => ItemType.getConsumeType(weaponType) != ItemType.Empty;
  int get equippedWeaponAmmoConsumption => ItemType.getConsumeAmount(weaponType);
  int get equippedWeaponAmmunitionType => ItemType.getConsumeType(weaponType);
  int get equippedWeaponCapacity => ItemType.getMaxQuantity(weaponType);

  bool get sufficientAmmunition => equippedWeaponQuantity > 1;

  int get equippedWeaponQuantity =>
    inventoryGetItemQuantity(equippedWeaponIndex);

  void lookAt(Position position) {
    assert(!dead);
    lookRadian = this.getAngle(position) + pi;
  }

  void inventoryClear() {
     for (var i = 0; i < inventory.length; i++){
       inventory[i] = ItemType.Empty;
       inventoryQuantity[i] = 0;
     }
     belt1_itemType = ItemType.Empty;
     belt2_itemType = ItemType.Empty;
     belt3_itemType = ItemType.Empty;
     belt4_itemType = ItemType.Empty;
     belt5_itemType = ItemType.Empty;
     belt6_itemType = ItemType.Empty;
     belt1_quantity = 0;
     belt2_quantity = 0;
     belt3_quantity = 0;
     belt4_quantity = 0;
     belt5_quantity = 0;
     belt6_quantity = 0;
     inventoryDirty = true;
  }

  void writeGameStatus(int gameStatus){
    writeByte(ServerResponse.Game_Status);
    writeByte(gameStatus);
  }

  void writeDouble(double value){
    writeInt16(value.toInt());
  }

  void writePlayerEnergy() {
    writeUInt8(ServerResponse.Api_Player);
    writeUInt8(ApiPlayer.Energy);
    if (maxEnergy == 0) return writeByte(0);
    writePercentage(energy / maxEnergy);
    // if (maxEnergy <= 0) {
    //   writeByte(0);
    // }
    // writePercentage(value)
    // writeUInt16(energy);
    // writeUInt16(maxEnergy);
  }

  void writeGameObject(IsometricGameObject gameObject){
    writeUInt8(ServerResponse.GameObject);
    writeUInt16(gameObject.id);
    writeBool(gameObject.active);
    writeUInt16(gameObject.type);
    writeVector3(gameObject);
  }

  void writeMap(Map<int, int> map){
    final entries = map.entries;
    writeUInt16(entries.length);
    for (final entry in entries) {
      writeUInt16(entry.key);
      writeUInt16(entry.value);
    }
  }

  int getItemIndex(int itemType) {
    final itemEntries = item_level.entries;
    var index = 0;
    for (var item in itemEntries){
      if (item.key == itemType) return index;
      index++;
    }
    return -1;
  }

  int getEquippedItemGroupItem(ItemGroup itemGroup) {
     switch (itemGroup){
       case ItemGroup.Primary_Weapon:
         return weaponPrimary;
       case ItemGroup.Secondary_Weapon:
         return weaponSecondary;
       case ItemGroup.Tertiary_Weapon:
         return weaponTertiary;
       case ItemGroup.Head_Type:
         return headType;
       case ItemGroup.Body_Type:
         return bodyType;
       case ItemGroup.Legs_Type:
         return legsType;
       case ItemGroup.Unknown:
         throw Exception('player.getEquippedItemGroupItem($itemGroup)');
     }
  }

  @override
  void onEquipmentChanged() {
    refreshDamage();
    writePlayerEquipment();
  }

  @override
  void onWeaponChanged() {
    refreshDamage();
    writePlayerWeapons();
  }

  void writePlayerEquipment(){
     writeByte(ServerResponse.Api_Player);
     writeByte(ApiPlayer.Equipment);
     writeUInt16(weaponType);
     writeUInt16(headType);
     writeUInt16(bodyType);
     writeUInt16(legsType);
  }

  void writeMapListInt(Map<int, List<int>> value){
    final entries = value.entries;
    writeUInt16(entries.length);
    for (final entry in entries) {
      writeUInt16(entry.key);
      writeUInt16(entry.value.length);
      writeUint16List(entry.value);
    }
  }

  int getNextItemFromItemGroup(ItemGroup itemGroup){

    final equippedItemType = getEquippedItemGroupItem(itemGroup);
    assert (equippedItemType != -1);
    final equippedItemIndex = getItemIndex(equippedItemType);
    assert (equippedItemType != -1);

    final itemEntries = item_level.entries.toList(growable: false);
    final itemEntriesLength = itemEntries.length;
    for (var i = equippedItemIndex + 1; i < itemEntriesLength; i++){
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      return entryItemType;
    }

    for (var i = 0; i < equippedItemIndex; i++){
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      return entryItemType;
    }

    return ItemType.Empty;
  }

  void swapWeapons() {
    if (!canChangeEquipment) {
      return;
    }

    final a = weaponPrimary;
    final b = weaponSecondary;

    weaponPrimary = b;
    weaponSecondary = a;
    game.setCharacterStateChanging(this);
    writePlayerEquipment();
  }

  int getItemLevel(int itemType) => item_level[itemType] ?? 0;

  int getItemQuantity(int itemType) => item_quantity[itemType] ?? 0;

  void writePlayerGrenades() {
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Grenades);
      writeUInt16(grenades);
  }

  writePlayerApiId(){
    writeUInt8(ServerResponse.Api_Player);
    writeUInt8(ApiPlayer.Id);
    writeUInt24(id);
  }

  @override
  bool get isPlayer => true;

  void writeApiPlayersAll() {
     writeUInt8(ServerResponse.Api_Players);
     writeUInt8(ApiPlayers.All);
     writeUInt16(game.players.length);
     for (final player in game.players) {
        writeUInt24(player.id);
        writeString(player.name);
        writeUInt24(player.score);
     }
  }

  void writeApiPlayersScore() {
    writeUInt8(ServerResponse.Api_Players);
    writeUInt8(ApiPlayers.All);
    writeUInt16(game.players.length);
    for (final player in game.players) {
      writeUInt24(player.id);
      writeString(player.name);
      writeUInt24(player.score);
    }
  }

  void writeApiPlayerAttributes(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Attributes);
    writeUInt16(_attributes);
  }

  void writeApiPlayersPlayerScore(IsometricPlayer player) {
    writeUInt8(ServerResponse.Api_Players);
    writeUInt8(ApiPlayers.Score);
    writeUInt24(player.id);
    writeUInt24(player.score);
  }

  void writeGameEventGameObjectDestroyed(IsometricGameObject gameObject){
    writeGameEvent(
      type: GameEventType.Game_Object_Destroyed,
      x: gameObject.x,
      y: gameObject.y,
      z: gameObject.z,
      angle: gameObject.velocityAngle,
    );
    writeUInt16(gameObject.type);
  }

  void writePlayerPower() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Power);
    writeByte(powerType);
    writeBool(powerCooldown <= 0);
  }

  void writeApiPlayerPerkType(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.PerkType);
    writeByte(perkType);
  }

  void writeApiPlayerRespawnTimer(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Respawn_Timer);
    writeUInt16(_respawnTimer);
  }

  @override
  void onTeamChanged() => writePlayerTeam();


  void writePlayerTeam(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Team);
    writeByte(team);
  }
}


