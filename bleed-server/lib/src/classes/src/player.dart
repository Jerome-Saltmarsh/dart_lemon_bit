
import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_server/src/system.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';
import '../../dark_age/areas/dark_age_area.dart';
import '../../dark_age/game_dark_age.dart';
import '../../dark_age/game_dark_age_editor.dart';
import 'scene_writer.dart';

class Player extends Character with ByteWriter {
  /// CONSTANTS
  static const Health_Per_Perk = 5;
  static const Frames_Per_Energy_Gain = 150;

  /// Variables
  final mouse = Vector2(0, 0);
  final runTarget = Position3();
  late Function sendBufferToClient;
  GameObject? editorSelectedGameObject;
  var _gold = 0;
  var debug = false;
  var framesSinceClientRequest = 0;
  var textDuration = 0;
  var _experience = 0;
  var _level = 1;
  var _attributes = 0;
  var _energy = 100;
  var maxEnergy = 100;
  var message = "";
  var text = "";
  var name = 'anon';
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var sceneDownloaded = false;
  var initialized = false;

  var inventoryDirty = false;
  var _equippedWeaponIndex = 0;

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

  var _baseHealth = 10;
  var _baseDamage = 0;
  var _baseEnergy = 10;

  /// Warning - do not reference
  Game game;
  Collider? _aimTarget; // the currently highlighted character
  Account? account;
  var perkMaxHealth = 0;
  var perkMaxDamage = 0;
  static const InventorySize = 6 * 5;
  final inventory = Uint16List(InventorySize);
  final inventoryQuantity = Uint16List(InventorySize);
  var storeItems = <int>[];
  final questsInProgress = <Quest>[];
  final questsCompleted = <Quest>[];
  final flags = <Flag>[];
  var options = <String, Function> {};
  var _interactMode = InteractMode.Inventory;
  var inventoryOpen = true;
  var mapX = 0;
  var mapY = 0;
  var nextEnergyGain = Frames_Per_Energy_Gain;

  /// CONSTRUCTOR
  Player({
    required this.game,
  }) : super(
    characterType: CharacterType.Template,
    x: 0,
    y: 0,
    z: 0,
    health: 10,
    team: 0,
    weaponType: 0,
    bodyType: ItemType.Body_Tunic_Padded,
    headType: ItemType.Head_Rogues_Hood,
    damage: 1,
  ){
    maxEnergy = energy;
    _energy = maxEnergy;
    game.players.add(this);
    game.characters.add(this);
  }

  /// GETTERS
  Collider? get aimTarget => _aimTarget;
  int get baseMaxHealth => _baseHealth;
  int get baseDamage => _baseDamage;
  int get gold => _gold;
  int get level => _level;
  int get attributes => _attributes;
  int get equippedWeaponIndex => _equippedWeaponIndex;
  int get lookDirection => Direction.fromRadian(lookRadian);
  int get experience => _experience;
  int get energy => _energy;
  int get experienceRequiredForNextLevel => getExperienceForLevel(level + 1);
  bool get weaponIsEquipped => _equippedWeaponIndex != -1;
  double get mouseGridX => (mouse.x + mouse.y) + z;
  double get mouseGridY => (mouse.y - mouse.x) + z;
  int get interactMode => _interactMode;
  /// in radians
  double get mouseAngle => getAngleBetween(mouseGridX, mouseGridY, x, y);
  Scene get scene => game.scene;
  double get magicPercentage {
    if (_energy == 0) return 0;
    if (maxEnergy == 0) return 0;
    return _energy / maxEnergy;
  }

  double get experiencePercentage {
    if (experienceRequiredForNextLevel <= 0) return 1.0;
    return _experience / experienceRequiredForNextLevel;
  }

  /// SETTERS
  set baseMaxHealth(int value){
     assert (value > 0);
     if (_baseHealth == value) return;
     _baseHealth = value;
     writePlayerBaseDamageHealthEnergy();
     // writePlayerBaseMaxHealth();
  }

  set baseDamage(int value){
    assert (value > 0);
    if (_baseDamage == value) return;
    _baseDamage = value;
    writePlayerBaseDamageHealthEnergy();
    // writePlayerBaseDamage();
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
      refreshStats();
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

  set attributes(int value){
    assert (value >= 0);
    if (_attributes == value) return;
    _attributes = value;
    writePlayerAttributes();
  }

  set gold(int value) {
    if (_gold == value) return;
    _gold = clamp(value, 0, 65000);
    writePlayerGold();
  }

  set aimTarget(Collider? collider) {
    if (_aimTarget == collider) return;
    if (collider == this) return;
    _aimTarget = collider;
    writePlayerAimTargetCategory();
    writePlayerAimTargetType();
    writePlayerAimTargetPosition();
    writePlayerAimTargetName();
    writePlayerAimTargetQuantity();
  }

  set energy(int value) {
    final clampedValue = clamp(value, 0, maxEnergy);
    if (_energy == clampedValue) return;
    _energy = clampedValue;
    writePlayerEnergy();
  }

  /// METHODS
  void refreshStats() {
      damage = baseDamage
          + (headType == ItemType.Empty ? 0 : ItemType.getDamage(headType))
          + (bodyType == ItemType.Empty ? 0 : ItemType.getDamage(bodyType))
          + (legsType == ItemType.Empty ? 0 : ItemType.getDamage(legsType))
          + (ItemType.getDamage(weaponType));

      maxHealth = baseMaxHealth
          + ItemType.getMaxHealth(headType)
          + ItemType.getMaxHealth(bodyType)
          + ItemType.getMaxHealth(legsType)
          + ItemType.getMaxHealth(weaponType);

      maxEnergy = _baseEnergy
          + ItemType.getEnergy(headType)
          + ItemType.getEnergy(bodyType)
          + ItemType.getEnergy(legsType)
          + ItemType.getEnergy(weaponType);

      if (ItemType.isTypeTrinket(belt1_itemType)) {
        maxHealth += ItemType.getMaxHealth(belt1_itemType);
        maxEnergy += ItemType.getEnergy(belt1_itemType);
        damage += ItemType.getDamage(belt1_itemType);

      }
      if (ItemType.isTypeTrinket(belt2_itemType)) {
        maxHealth += ItemType.getMaxHealth(belt2_itemType);
        maxEnergy += ItemType.getEnergy(belt2_itemType);
        damage += ItemType.getDamage(belt2_itemType);
      }
      if (ItemType.isTypeTrinket(belt3_itemType)) {
        maxHealth += ItemType.getMaxHealth(belt3_itemType);
        maxEnergy += ItemType.getEnergy(belt3_itemType);
        damage += ItemType.getDamage(belt3_itemType);
      }
      if (ItemType.isTypeTrinket(belt4_itemType)) {
        maxHealth += ItemType.getMaxHealth(belt4_itemType);
        maxEnergy += ItemType.getEnergy(belt4_itemType);
        damage    += ItemType.getDamage(belt4_itemType);
      }
      if (ItemType.isTypeTrinket(belt5_itemType)){
        maxHealth += ItemType.getMaxHealth(belt5_itemType);
        maxEnergy += ItemType.getEnergy(belt6_itemType);
        damage    += ItemType.getDamage(belt5_itemType);
      }
      if (ItemType.isTypeTrinket(belt6_itemType)) {
        maxHealth += ItemType.getMaxHealth(belt6_itemType);
        maxEnergy += ItemType.getEnergy(belt6_itemType);
        damage    += ItemType.getDamage(belt6_itemType);
      }

      maxHealth += perkMaxHealth * Health_Per_Perk;
      damage += perkMaxDamage;

      if (health > maxHealth){
        health = maxHealth;
      }
      if (energy > maxEnergy){
        energy = maxEnergy;
      }

      assert (damage > 0);

      writePlayerPerks();
      writePlayerMaxHealth();
      writePlayerHealth();
      writePlayerDamage();
  }

  void unequipWeapon(){
    _equippedWeaponIndex = -1;
    weaponType = ItemType.Empty;
    inventoryDirty = true;
    game.setCharacterStateChanging(this);
    refreshStats();
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
      attributes += 3;
      game.customOnPlayerLevelGained(this);
      writePlayerEvent(PlayerEvent.Level_Increased);
    }
    writePlayerExperiencePercentage();
  }

  bool questToDo(Quest quest) => !questCompleted(quest) && !questInProgress(quest);
  bool questInProgress(Quest quest) => questsInProgress.contains(quest);
  bool questCompleted(Quest quest) => questsCompleted.contains(quest);
  bool flag(Flag flag) {
    if (flagged(flag)) return false;
    flags.add(flag);
    return true;
  }
  bool flagged(Flag flag) => flags.contains(flag);


  void beginQuest(Quest quest){
    assert (!questsInProgress.contains(quest));
    assert (!questsCompleted.contains(quest));
    questsInProgress.add(quest);
    writePlayerQuests();
    writePlayerEvent(PlayerEvent.Quest_Started);
  }

  void completeQuest(Quest quest){
    assert (questsInProgress.contains(quest));
    assert (!questsCompleted.contains(quest));
    questsInProgress.remove(quest);
    questsCompleted.add(quest);
    writePlayerQuests();
    writePlayerEvent(PlayerEvent.Quest_Completed);
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
     writeError('invalid inventory index: $index (${ItemType.getName(index)})');
  }

  void writeErrorInsufficientArgs(){
      writeError('insufficient args');
  }

  void writeErrorInvalidIndex(int index){
    writeError('invalid index $index');
  }

  void writeError(String error){
      writeByte(ServerResponse.Error);
      writeString(error);
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
      writeError('not in trade mode');
      return;
    }
    if (index < 0) {
      writeErrorInvalidIndex(index);
      return;
    }
    if (index >= storeItems.length) {
      writeErrorInvalidIndex(index);
      return;
    }
    final itemType = storeItems[index];
    if (itemType == ItemType.Empty) {
      writeError('item type is empty');
      return;
    }

    final recipe = ItemType.Recipes[itemType];

    if (recipe != null) {
       for (var i = 0; i < recipe.length; i += 2) {
         final recipeItemQuantity = recipe[i];
         final recipeItemType = recipe[i + 1];
         final quantityInPossession = inventoryGetTotalQuantityOfItemType(recipeItemType);
         if (quantityInPossession < recipeItemQuantity) {
           writeError('insufficient ${ItemType.getName(recipeItemType)} ($quantityInPossession / $recipeItemQuantity)');
           return;
         }
       }

       for (var i = 0; i < recipe.length; i += 2) {
         inventoryReduceItemTypeQuantity(
            reduction: recipe[i],
            itemType: recipe[i + 1]
         );
      }
    }
    inventoryDirty = true;
    writePlayerEventItemPurchased(itemType);
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
    refreshStats();
  }

  void inventorySwapIndexes(int indexA, int indexB){
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
       writeError('${ItemType.getName(itemType)} consumed');
       return;
    }

    if (index < inventory.length) {
      final emptyBeltIndex = getEmptyBeltIndex();
      if (emptyBeltIndex != null) {
        inventorySwapIndexes(index, emptyBeltIndex);
      } else {
        writeError('belt is full');
      }
      return;
    }

    if (ItemType.isIndexBelt(index)){
      final emptyInventoryIndex = getEmptyInventoryIndex();
      if (emptyInventoryIndex != null) {
        inventorySwapIndexes(index, emptyInventoryIndex);
      } else {
        writeError('inventory is full');
      }
      return;
    }
  }

  void setInventoryDirty(){
    game.setCharacterStateChanging(this);
    inventoryDirty = true;
  }

  void writePlayerPosition(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Position);
    writePosition3(this);
  }

  void writePlayerHealth(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Health);
    writeUInt16(health);
  }

  void writePlayerMaxHealth() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Max_Health);
    writeUInt16(maxHealth); // 2
  }

  void writePlayerBaseDamageHealthEnergy(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Base_Damage_Health_Energy);
    writeUInt16(_baseDamage);
    writeUInt16(_baseHealth);
    writeUInt16(_baseEnergy);
  }

  void writePlayerPerks() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Perks);
    writeByte(perkMaxHealth);
    writeByte(perkMaxDamage);
  }

  void writePlayerDamage() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Damage);
    writeUInt16(damage);
  }

  void writePlayerAlive(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Alive);
    writeBool(alive);
  }

  void writePlayerExperiencePercentage(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Experience_Percentage);
    writePercentage(experiencePercentage);
  }

  void writePlayerLevel(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Level);
    writeUInt16(level);
  }

  void writePlayerAttributes(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Attributes);
    writeUInt16(attributes);
  }

  void writePlayerAimAngle(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Aim_Angle);
    writeAngle(mouseAngle);
  }

  void writePlayerGame() {
    writePlayerPosition();
    writePlayerWeaponCooldown();
    writePlayerAccuracy();
    writePlayerAimTargetPosition();

    writeProjectiles();
    writePlayerTargetPosition();
    writeCharacters();
    writeGameObjects();
    writeEditorGameObjectSelected();

    if (game.time.enabled){
      writeGameTime(game.time.time);
    }

    if (inventoryDirty) {
      inventoryDirty = false;
      writePlayerInventory();
    }

    if (!initialized) {
      game.customInitPlayer(this);
      game.customOnPlayerRevived(this);
      initialized = true;
      writePlayerPosition();
      writePlayerSpawned();
      writePlayerInventory();
      writePlayerLevel();
      writePlayerExperiencePercentage();
      // writePlayerBaseMaxHealth();
      // writePlayerBaseMaxHealth();
      writePlayerBaseDamageHealthEnergy();
      writePlayerHealth();
      writePlayerMaxHealth();
      writePlayerAlive();
      writePlayerInteractMode();
    }

    if (!sceneDownloaded){
      downloadScene();
    }
  }

  void writePlayerStats(){
    refreshStats();
    writePlayerLevel();
    writePlayerExperiencePercentage();
    writePlayerBaseDamageHealthEnergy();
    writePlayerHealth();
    writePlayerEnergy();
    writePlayerMaxHealth();
    writePlayerAlive();
    writePlayerInteractMode();
  }

  void writePlayerWeaponCooldown() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Cooldown);
    writePercentage(weaponDurationPercentage);
  }

  void writePlayerAccuracy(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Accuracy);
    writePercentage(accuracy);
  }

  void writePlayerSelectHero(bool value){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Select_Hero);
    writeBool(value);
  }

  void writeGameObjects(){
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;

      const AlwaysSend = [
        ItemType.GameObjects_Crystal_Small_Blue,
        ItemType.GameObjects_Crystal_Small_Red,
        ItemType.GameObjects_Barrel_Flaming,
      ];

      if (!AlwaysSend.contains(gameObject.type)) {
        if (gameObject.renderY < screenTop) continue;
        if (gameObject.renderX < screenLeft) continue;
        if (gameObject.renderX > screenRight) continue;
        if (gameObject.renderY > screenBottom) continue;
      }
      writeByte(ServerResponse.GameObject);
      writeUInt16(gameObject.type);
      writePosition3(gameObject);
    }
  }

  void writeCharacters(){
    writeByte(ServerResponse.Characters);
    final characters = game.characters;
    for (final character in characters) {
      if (character.dead) continue;
      if (character.renderY < screenTop) continue;
      if (character.renderX < screenLeft) continue;
      if (character.renderX > screenRight) continue;
      if (character.renderY > screenBottom) {
        writeByte(END);
        return;
      }

      writeByte(character.characterType);
      writeCharacterTeamDirectionAndState(character);
      writeVector3(character);
      writeCharacterHealthAndAnimationFrame(character);

      if (CharacterType.supportsUpperBody(character.characterType)) {
        writeCharacterUpperBody(character);
      }
    }
    writeByte(END);
  }

  void writeCharacterTeamDirectionAndState(Character character){
    writeByte((Collider.onSameTeam(this, character) ? 100 : 0) + (character.faceDirection * 10) + character.state); // 1
  }

  // todo optimize
  void writeCharacterHealthAndAnimationFrame(Character character) =>
    writeByte((((character.health / character.maxHealth) * 24).toInt() * 10) + character.animationFrame);

  void downloadScene(){
    writeGrid();
    writeGameProperties();
    writeMapCoordinate();
    writeRenderMap(game.customPropMapVisible);
    writeGameType(game.gameType);
    writeWeather();
    game.customDownloadScene(this);
    writePlayerEvent(PlayerEvent.Scene_Changed);
    sceneDownloaded = true;
  }

  void writeRenderMap(bool value){
    writeByte(ServerResponse.Render_Map);
    writeBool(value);
  }

  void writeGameType(int value){
    writeByte(ServerResponse.Game_Type);
    writeByte(value);
  }

  void writePlayerSpawned(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Spawned);
  }

  void writeAndSendResponse(){
    writePlayerGame();
    game.customPlayerWrite(this);
    writeByte(ServerResponse.End);
    sendBufferToClient();
  }

  void writePlayerTargetPosition(){
    if (target == null) return;
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Target_Position);
    writePosition3(target!);
  }

  void writePlayerTargetCategory(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Target_Category);
    writeByte(getAimCategory(target));
  }

  void writePlayerAimTargetPosition(){
    if (aimTarget == null) return;
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Aim_Target_Position);
    writePosition3(aimTarget!);
  }

  void writePlayerAimTargetCategory() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Aim_Target_Category);
    writeByte(getAimCategory(aimTarget));
  }

  void writePlayerAimTargetType() {
    if (aimTarget == null) return;
    if (aimTarget is GameObject){
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as GameObject).type);
    }
    if (aimTarget is Character) {
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as Character).characterType);
    }
  }

  void writePlayerAimTargetQuantity() {
    if (aimTarget is GameObject) {
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Quantity);
      writeUInt16((aimTarget as GameObject).quantity);
    }
  }

  void writePlayerAimTargetName() {
    if (aimTarget == null) return;

    if (aimTarget is Player){
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Name);
      writeString((aimTarget as Player).name);
      return;
    }
    if (aimTarget is AI){
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Name);
      writeString((aimTarget as AI).name);
      return;
    }
  }

  int getAimCategory(Position3? value){
    if (value == null) return TargetCategory.Nothing;
    if (value is GameObject) {
      if (value.collectable) return TargetCategory.Item;
      if (value.interactable) return TargetCategory.Allie;
      return TargetCategory.GameObject;
    }
    if (isAllie(value)) return TargetCategory.Allie;
    if (isEnemy(value)) return TargetCategory.Enemy;
    return TargetCategory.Run;
  }

  bool onScreen(double x, double y){
    const Max_Distance = 800.0;
    if ((this.x - x).abs() > Max_Distance) return false;
    if ((this.y - y).abs() > Max_Distance) return false;
    return true;
  }

  bool isAllie(Position3? value)=> Collider.onSameTeam(this, value);
  bool isEnemy(Position3? value) => !Collider.onSameTeam(this, value);

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


  void writePlayerEventItemPurchased(int itemType){
    writePlayerEvent(PlayerEvent.Item_Purchased);
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

  void writePlayerEventItemEquipped(int itemType){
    writePlayerEvent(PlayerEvent.Item_Equipped);
    writeByte(itemType);
  }

  void writePlayerMessage(String message){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Message);
    writeString(message);
  }

  void writeGameTime(int time){
    writeByte(ServerResponse.Game_Time);
    final totalMinutes = time ~/ 60;
    writeByte(totalMinutes ~/ 60);
    writeByte(totalMinutes % 60);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    writePosition(projectile);
    writeDouble(projectile.z);
    writeByte(projectile.type);
    writeAngle(projectile.velocityAngle);
  }

  void writeCharacterUpperBody(Character character) {
    assert (ItemType.isTypeWeapon(character.weaponType) || character.weaponType == ItemType.Empty);
    assert (ItemType.isTypeLegs(character.legsType) || character.legsType == ItemType.Empty);
    assert (ItemType.isTypeBody(character.bodyType) || character.bodyType == ItemType.Empty);
    assert (ItemType.isTypeHead(character.headType) || character.headType == ItemType.Empty);
    writeUInt16(character.weaponType);
    writeUInt16(character.weaponState);
    writeUInt16(character.bodyType); // armour
    writeUInt16(character.headType); // helm
    writeUInt16(character.legsType); // helm
    writeAngle(character.lookRadian);
    writeByte(character.weaponFrame);
  }

  void writeWeather() {
    final environment = game.environment;

    final underground = game is GameDarkAge && (game as GameDarkAge).underground;

    if (underground) {
      writeByte(ServerResponse.Weather);
      writeByte(RainType.None);
      writeBool(false);
      writeByte(LightningType.Off);
      writeByte(WindType.Calm);
    } else {
      writeByte(ServerResponse.Weather);
      writeByte(environment.rainType);
      writeBool(environment.breezy);
      writeByte(environment.lightningType);
      writeByte(environment.windType);
    }

    writeEnvironmentUnderground(underground);
    writeGameTimeEnabled();
  }

  void writePercentage(double value){
    if (value.isNaN) {
      writeByte(0);
      return;
    }
    writeByte((value * 256).toInt());
  }

  void writePosition(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
  }

  void writePosition3(Position3 value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeVector3(Position3 value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeGrid() {
    writeByte(ServerResponse.Grid);
    var compiled = scene.compiled;
    if (compiled == null){
      compiled = SceneWriter.compileScene(scene, gameObjects: false);
      scene.compiled = compiled;
    }
    writeBytes(compiled);
  }

  void writePlayerGold(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Gold);
    writeUInt16(gold);
  }

  void writePlayerInventory() {
    writeByte(ServerResponse.Player);
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
    writeByte(ServerResponse.Player);
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
    writeBool((game is GameDarkAgeEditor || isLocalMachine));
    writeString(game.scene.name);
    writeBool(game.running);
  }

  void writePlayerQuests(){
    writeByte(ServerResponse.Player_Quests);
    writeUInt16(questsInProgress.length);
    for (final quest in questsInProgress){
      writeByte(quest.index);
    }
    writeUInt16(questsCompleted.length);
    for (final quest in questsCompleted){
      writeByte(quest.index);
    }
  }

  void writeMapCoordinate() {
    if (game is DarkAgeArea == false) return;
    final area = game as DarkAgeArea;
    writeByte(ServerResponse.Map_Coordinate);
    writeByte(area.mapTile);
  }

  void writeEditorGameObjectSelected() {
    final selectedGameObject = editorSelectedGameObject;
    if (selectedGameObject == null) return;
    writeByte(ServerResponse.Editor_GameObject_Selected);
    writePosition3(selectedGameObject);
    writeUInt16(selectedGameObject.type);
    writeBool(selectedGameObject.collidable);
    writeBool(selectedGameObject.movable);
    writeBool(selectedGameObject.collectable);
    writeBool(selectedGameObject.physical);
    writeBool(selectedGameObject.persistable);
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

  void writeEnvironmentTime(int value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Time);
    writeByte(value);
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
     writeByte(ServerResponse.Player);
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
    assert(!deadOrDying);
    lookRadian = this.getAngle(position) + pi;
  }

  void selectPerk(int perkType) {
    switch (perkType) {
      case PerkType.Max_Health:
        perkMaxHealth++;
        refreshStats();
        break;
      case PerkType.Damage:
        perkMaxDamage++;
        refreshStats();
        break;
    }
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
    writeUInt8(ServerResponse.Player);
    writeUInt8(ApiPlayer.Energy);
    writeUInt16(energy);
    writeUInt16(maxEnergy);
  }
}

int getExperienceForLevel(int level){
  return (((level - 1) * (level - 1))) * 6;
}
