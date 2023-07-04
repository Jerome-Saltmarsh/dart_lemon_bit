
import 'dart:math';
import 'dart:typed_data';

import 'package:gamestream_server/isometric/src.dart';
import 'package:gamestream_server/common/src.dart';
import 'package:lemon_math/src.dart';

import 'survival_game.dart';

class SurvivalPlayer extends IsometricPlayer {

  static const inventory_size = 6 * 5;

  final inventory = Uint16List(inventory_size);
  final inventoryQuantity = Uint16List(inventory_size);
  final inventoryUpgrades = Uint16List(inventory_size);

  var inventoryOpen = false;
  var inventoryDirty = false;
  var energy = 0;
  var npcOptions = <String, Function> {};

  var storeItems = <int>[];
  var belt1_itemType = ObjectType.Nothing; // 1
  var belt2_itemType = ObjectType.Nothing; // 2
  var belt3_itemType = ObjectType.Nothing; // 3
  var belt4_itemType = ObjectType.Nothing; // 4
  var belt5_itemType = ObjectType.Nothing; // Q
  var belt6_itemType = ObjectType.Nothing; // E

  var belt1_quantity = 0; // 1
  var belt2_quantity = 0; // 2
  var belt3_quantity = 0; // 3
  var belt4_quantity = 0; // 4
  var belt5_quantity = 0; // Q
  var belt6_quantity = 0; // E

  var _interactMode = InteractMode.Inventory;
  var _equippedWeaponIndex = 0;

  final SurvivalGame game;

  SurvivalPlayer(this.game) : super(game: game);

  int getConsumeAmount(int weaponType){
    return 1;
  }

  int getConsumeType(int weaponType){
    return 1;
  }

  int getMaxQuantity(int weaponType){
    return 1;
  }

  int get equippedWeaponIndex => _equippedWeaponIndex;
  bool get weaponIsEquipped => _equippedWeaponIndex != -1;

  int get equippedWeaponAmmoConsumption => getConsumeAmount(weaponType);
  int get equippedWeaponAmmunitionType => getConsumeType(weaponType);
  int get equippedWeaponCapacity => getMaxQuantity(weaponType);
  bool get sufficientAmmunition => equippedWeaponQuantity > 1;

  int get equippedWeaponQuantity =>
      inventoryGetItemQuantity(equippedWeaponIndex);

  int get interactMode => _interactMode;

  bool isTypeWeapon(int index){
    return true;
  }

  set equippedWeaponIndex(int index){
    if (_equippedWeaponIndex == index) return;
    if (index == -1){
      unequipWeapon();
      return;
    }
    assert (isValidInventoryIndex(index));

    final itemTypeAtIndex = inventoryGetItemType(index);

    if (isTypeWeapon(itemTypeAtIndex)){
      _equippedWeaponIndex = index;
      weaponType = itemTypeAtIndex;
      inventoryDirty = true;
      weaponState = WeaponState.Changing;
      game.dispatchV3(GameEventType.Character_Changing, this);
      refreshDamage();
      return;
    }

    unequipWeapon();
    return;
  }

  set interactMode(int value){
    if (_interactMode == value) return;
    _interactMode = value;
    writePlayerInteractMode();
  }

  void playerReload(SurvivalPlayer player) {
    final equippedWeaponAmmoType = player.equippedWeaponAmmunitionType;
    final totalAmmoRemaining = player.inventoryGetTotalQuantityOfItemType(
        equippedWeaponAmmoType);

    if (totalAmmoRemaining == 0) {
      player.writeGameError(GameError.Insufficient_Ammunition);
      return;
    }
    var total = min(totalAmmoRemaining, player.equippedWeaponCapacity);
    player.inventoryReduceItemTypeQuantity(
      itemType: equippedWeaponAmmoType,
      reduction: total,
    );
    player.inventorySetQuantityAtIndex(
      quantity: total,
      index: player.equippedWeaponIndex,
    );
    player.assignWeaponStateReloading();
  }

  void unequipWeapon(){
    _equippedWeaponIndex = -1;
    weaponType = WeaponType.Unarmed;
    inventoryDirty = true;
    game.setCharacterStateChanging(this);
    refreshDamage();
  }

  int? getEmptyBeltIndex(){
    // if (belt1_itemType == ItemType.Nothing) return ItemType.Belt_1;
    // if (belt2_itemType == ItemType.Nothing) return ItemType.Belt_2;
    // if (belt3_itemType == ItemType.Nothing) return ItemType.Belt_3;
    // if (belt4_itemType == ItemType.Nothing) return ItemType.Belt_4;
    // if (belt5_itemType == ItemType.Nothing) return ItemType.Belt_5;
    // if (belt6_itemType == ItemType.Nothing) return ItemType.Belt_6;
    return null;
  }

  int inventoryGetItemType(int index){
    return -1;
    // if (index == -1){
    //   throw Exception();
    // }
    // if (index == ItemType.Equipped_Weapon)
    //   return weaponType;
    // if (index == ItemType.Equipped_Body)
    //   return bodyType;
    // if (index == ItemType.Equipped_Head)
    //   return headType;
    // if (index == ItemType.Equipped_Legs)
    //   return legsType;
    //
    // if (index == ItemType.Belt_1)
    //   return belt1_itemType;
    // if (index == ItemType.Belt_2)
    //   return belt2_itemType;
    // if (index == ItemType.Belt_3)
    //   return belt3_itemType;
    // if (index == ItemType.Belt_4)
    //   return belt4_itemType;
    // if (index == ItemType.Belt_5)
    //   return belt5_itemType;
    // if (index == ItemType.Belt_6)
    //   return belt6_itemType;
    //
    // assert(index < inventory.length);
    // return inventory[index];
  }

  void inventoryDrop(int index) {
    assert (isValidInventoryIndex(index));
    dropItemType(itemType: inventoryGetItemType(index), quantity: inventoryGetItemQuantity(index));
    inventorySetEmptyAtIndex(index);
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
    return -1;
    // assert (index >= 0);
    // assert (isValidInventoryIndex(index));
    //
    // final itemType = inventoryGetItemType(index);
    // if (itemType == ItemType.Empty) return 0;
    // // if (ItemType.doesConsumeOnUse(itemType)) return 1;
    //
    // // if (index == ItemType.Equipped_Weapon)
    // //   return 1;
    // if (index == ItemType.Equipped_Body)
    //   return 1;
    // if (index == ItemType.Equipped_Head)
    //   return 1;
    // if (index == ItemType.Equipped_Legs)
    //   return 1;
    //
    // if (index == ItemType.Belt_1)
    //   return belt1_quantity;
    // if (index == ItemType.Belt_2)
    //   return belt2_quantity;
    // if (index == ItemType.Belt_3)
    //   return belt3_quantity;
    // if (index == ItemType.Belt_4)
    //   return belt4_quantity;
    // if (index == ItemType.Belt_5)
    //   return belt5_quantity;
    // if (index == ItemType.Belt_6)
    //   return belt6_quantity;
    //
    // assert(index < inventoryQuantity.length);
    // return inventoryQuantity[index];
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
    // if (itemType == ItemType.Empty) {
    //   writeGameError(GameError.Invalid_Purchase_index);
    //   return;
    // }

    inventoryDirty = true;
    final emptyInventoryIndex = getEmptyInventoryIndex();
    if (emptyInventoryIndex == null) {
      // game.spawnGameObjectItemAtPosition(position: this, type: itemType, quantity: 1);
      writePlayerEvent(PlayerEvent.Inventory_Full);
      return;
    }
    inventory[emptyInventoryIndex] = itemType;

    var quantity = 1;
    // if (ItemType.isTypeWeapon(itemType)){
    //   quantity = ItemType.getMaxQuantity(itemType);
    // }
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

    // for (final beltIndex in ItemType.Belt_Indexes){
    //   if (inventoryGetItemType(beltIndex) != itemType) continue;
    //   final beltQuantity = inventoryGetItemQuantity(beltIndex);
    //   if (beltQuantity >= reductionRemaining) {
    //     inventorySetQuantityAtIndex(quantity: beltQuantity - reductionRemaining, index: beltIndex);
    //     return;
    //   }
    //   inventorySetEmptyAtIndex(beltIndex);
    // }
  }

  void inventorySetQuantityAtIndex({required int quantity, required int index}){
    // assert (isValidInventoryIndex(index));
    // final itemType = inventoryGetItemType(index);
    //
    // if (quantity == 0) {
    //   if (ItemType.isTypeResource(itemType)){
    //     inventorySetEmptyAtIndex(index);
    //   }
    // }
    // if (index < inventory.length) {
    //   inventoryQuantity[index] = quantity;
    //   return;
    // }
    // if (index == ItemType.Belt_1){
    //   belt1_quantity = quantity;
    //   if (belt1_quantity == 0 && removeOnEmpty(itemType)){
    //     inventorySetEmptyAtIndex(ItemType.Belt_1);
    //   }
    //   return;
    // }
    // if (index == ItemType.Belt_2){
    //   belt2_quantity = quantity;
    //   if (belt2_quantity == 0 && removeOnEmpty(itemType)){
    //     inventorySetEmptyAtIndex(ItemType.Belt_2);
    //   }
    //   return;
    // }
    // if (index == ItemType.Belt_3){
    //   belt3_quantity = quantity;
    //   if (belt3_quantity == 0 && removeOnEmpty(itemType)){
    //     inventorySetEmptyAtIndex(ItemType.Belt_3);
    //   }
    //   return;
    // }
    // if (index == ItemType.Belt_4){
    //   belt4_quantity = quantity;
    //   if (belt4_quantity == 0 && removeOnEmpty(itemType)){
    //     inventorySetEmptyAtIndex(ItemType.Belt_4);
    //   }
    //   return;
    // }
    // if (index == ItemType.Belt_5){
    //   belt5_quantity = quantity;
    //   if (belt5_quantity == 0 && removeOnEmpty(itemType)){
    //     inventorySetEmptyAtIndex(ItemType.Belt_5);
    //   }
    //   return;
    // }
    // if (index == ItemType.Belt_6){
    //   belt6_quantity = quantity;
    //   if (belt6_quantity == 0 && removeOnEmpty(itemType)){
    //     inventorySetEmptyAtIndex(ItemType.Belt_6);
    //   }
    //   return;
    // }
  }

  void inventorySell(int index) {
    // if (interactMode != InteractMode.Trading) {
    //   writePlayerEventInvalidRequest();
    //   return;
    // }
    // if (!isValidInventoryIndex(index)) {
    //   writePlayerEventInvalidRequest();
    //   return;
    // }
    // final itemType = inventoryGetItemType(index);
    // if (itemType == ItemType.Empty) {
    //   writePlayerEventInvalidRequest();
    //   return;
    // }
    // inventorySetEmptyAtIndex(index);
    // writePlayerEvent(PlayerEvent.Item_Sold);
  }

  void inventorySet({
    required int index,
    required int itemType,
    required int itemQuantity,
  }){
    assert (isValidInventoryIndex(index));
    assert (itemTypeCanBeAssignedToIndex(itemType: itemType, index: index));
    // assert (itemType != ItemType.Empty || itemQuantity == 0);

    final maxQuantity = getMaxQuantity(itemType);
    itemQuantity = clamp(itemQuantity, 1, maxQuantity);

    if (index == equippedWeaponIndex) {
      // if (ItemType.isTypeWeapon(itemType)) {
      //   weaponType = itemType;
      //   inventoryDirty = true;
      //   game.setCharacterStateChanging(this);
      // }
      equippedWeaponIndex = -1;
    }

    // if (index == ItemType.Equipped_Weapon) {
    //   if (weaponType == itemType) return;
    //   weaponType = itemType;
    //   inventoryDirty = true;
    //   game.setCharacterStateChanging(this);
    // } else
    // if (index == ItemType.Equipped_Body) {
    //   bodyType = itemType;
    //   inventoryDirty = true;
    //   game.setCharacterStateChanging(this);
    // } else
    // if (index == ItemType.Equipped_Head) {
    //   headType = itemType;
    //   inventoryDirty = true;
    //   game.setCharacterStateChanging(this);
    // } else
    // if (index == ItemType.Equipped_Legs) {
    //   legsType = itemType;
    //   inventoryDirty = true;
    //   game.setCharacterStateChanging(this);
    // } else
    // if (index == ItemType.Belt_1){
    //   belt1_itemType = itemType;
    //   belt1_quantity = itemQuantity;
    //   inventoryDirty = true;
    // } else
    // if (index == ItemType.Belt_2){
    //   belt2_itemType = itemType;
    //   belt2_quantity = itemQuantity;
    //   inventoryDirty = true;
    // } else
    // if (index == ItemType.Belt_3){
    //   belt3_itemType = itemType;
    //   belt3_quantity = itemQuantity;
    //   inventoryDirty = true;
    // } else
    // if (index == ItemType.Belt_4){
    //   if (belt4_itemType == itemType) return;
    //   belt4_itemType = itemType;
    //   belt4_quantity = itemQuantity;
    //   inventoryDirty = true;
    // } else
    // if (index == ItemType.Belt_5){
    //   belt5_itemType = itemType;
    //   belt5_quantity = itemQuantity;
    //   inventoryDirty = true;
    // } else
    // if (index == ItemType.Belt_6){
    //   belt6_itemType = itemType;
    //   belt6_quantity = itemQuantity;
    //   inventoryDirty = true;
    // } else
    // if (index < inventory.length){
    //   inventory[index] = itemType;
    //   inventoryQuantity[index] = itemQuantity;
    //   inventoryDirty = true;
    // }
    refreshDamage();
  }

  void inventorySetEmptyAtIndex(int index) =>
      inventorySet(index: index, itemType: GameObjectType.Nothing, itemQuantity: 0)
  ;

  void inventorySwapIndexes(int indexA, int indexB) {
    if (indexA == indexB) return;
    assert (isValidInventoryIndex(indexA));
    assert (isValidInventoryIndex(indexB));
    final indexAType = inventoryGetItemType(indexA);
    final indexBType = inventoryGetItemType(indexB);
    final indexAQuantity = inventoryGetItemQuantity(indexA);
    final indexBQuantity = inventoryGetItemQuantity(indexB);

    // final weaponsSwapped = indexA == equippedWeaponIndex || indexB == equippedWeaponIndex;
    // final currentEquippedWeaponIndex = equippedWeaponIndex;

    if (indexAType == indexBType){
      // if (ItemType.isTypeResource(indexAType)){
      //   final total = indexAQuantity + indexBQuantity;
      //   final totalMax = ItemType.getMaxQuantity(indexAType);
      //   if (total < totalMax){
      //     inventorySetEmptyAtIndex(indexA);
      //     inventorySetQuantityAtIndex(quantity: total, index: indexB);
      //   } else {
      //     inventorySetQuantityAtIndex(quantity: total - totalMax, index: indexA);
      //     inventorySetQuantityAtIndex(quantity: totalMax, index: indexB);
      //   }
      //   inventoryDirty = true;
      //   assignWeaponStateChanging();
      //   game.dispatchV3(GameEventType.Character_Changing, this);
      //   return;
      // }
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

    // if (weaponsSwapped && ItemType.isTypeWeapon(indexAType) && ItemType.isTypeWeapon(indexBType)) {
    //   equippedWeaponIndex = currentEquippedWeaponIndex;
    // }
    weaponState = WeaponState.Changing;
    game.dispatchV3(GameEventType.Character_Changing, this);
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

  void inventoryAddMax({required int itemType}){
    inventoryAdd(itemType: itemType, itemQuantity: getMaxQuantity(itemType));
  }

  void inventoryEquip(int index) {

    // if (deadOrBusy) return;
    //
    // if (!isValidInventoryIndex(index)) {
    //   writePlayerEventInvalidRequest();
    //   return;
    // }
    //
    // // if (ItemType.isTypeEquipped(index)){
    // //   inventoryUnequip(index);
    // //   return;
    // // }
    //
    // final itemType = inventoryGetItemType(index);
    //
    // if (ItemType.isTypeWeapon(itemType)){
    //
    //   if (ItemType.isIndexBelt(index)){
    //     equippedWeaponIndex = index;
    //     return;
    //   }
    //
    //   // move an item from the inventory to the belt and equip it
    //   if (index < inventory.length) {
    //
    //     final emptyBeltIndex = getEmptyBeltIndex();
    //     if (emptyBeltIndex != null) {
    //       inventorySwapIndexes(index, emptyBeltIndex);
    //       equippedWeaponIndex = emptyBeltIndex;
    //       return;
    //     }
    //
    //     // if an item from the bag was selected but all belt slots are already being used
    //     if (equippedWeaponIndex != -1) {
    //       inventorySwapIndexes(index, equippedWeaponIndex);
    //       return;
    //     }
    //
    //     // if none of the belts items are weapons simply use the first index
    //     inventorySwapIndexes(index, ItemType.Belt_1);
    //     return;
    //   }
    // }
    // if (ItemType.isTypeHead(itemType)){
    //   inventorySwapIndexes(index, ItemType.Equipped_Head);
    //   return;
    // }
    // if (ItemType.isTypeBody(itemType)){
    //   inventorySwapIndexes(index, ItemType.Equipped_Body);
    //   return;
    // }
    // if (ItemType.isTypeLegs(itemType)){
    //   inventorySwapIndexes(index, ItemType.Equipped_Legs);
    //   return;
    // }
    // if (ItemType.isTypeConsumable(itemType)) {
    //   health += ItemType.getHealAmount(itemType);
    //   energy += ItemType.getReplenishEnergy(itemType);
    //   writePlayerEventItemTypeConsumed(itemType);
    //   final quantity = inventoryGetItemQuantity(index);
    //   final nextQuantity = quantity - 1;
    //   if (nextQuantity <= 0){
    //     inventorySetEmptyAtIndex(index);
    //   } else {
    //     inventorySetQuantityAtIndex(quantity: nextQuantity, index: index);
    //   }
    //   inventoryDirty = true;
    //   game.setCharacterStateChanging(this);
    //   // writeGameError('${ItemType.getName(itemType)} consumed');
    //   return;
    // }
    //
    // if (index < inventory.length) {
    //   final emptyBeltIndex = getEmptyBeltIndex();
    //   if (emptyBeltIndex != null) {
    //     inventorySwapIndexes(index, emptyBeltIndex);
    //   } else {
    //     writeGameError(GameError.Inventory_Equip_Failed_Belt_Full);
    //   }
    //   return;
    // }
    //
    // if (ItemType.isIndexBelt(index)){
    //   final emptyInventoryIndex = getEmptyInventoryIndex();
    //   if (emptyInventoryIndex != null) {
    //     inventorySwapIndexes(index, emptyInventoryIndex);
    //   } else {
    //     writeGameError(GameError.Inventory_Equip_Failed_Inventory_Full);
    //   }
    //   return;
    // }
  }

  @override
  void writePlayerGame() {
    super.writePlayerGame();
    if (inventoryDirty) {
      inventoryDirty = false;
      writePlayerInventory();
    }
  }

  void setInventoryDirty(){
    game.setCharacterStateChanging(this);
    inventoryDirty = true;
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


  void writePlayerEquippedWeaponAmmunition(){
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

  void inventoryClear() {
    // for (var i = 0; i < inventory.length; i++){
    //   inventory[i] = ItemType.Empty;
    //   inventoryQuantity[i] = 0;
    // }
    // belt1_itemType = ItemType.Empty;
    // belt2_itemType = ItemType.Empty;
    // belt3_itemType = ItemType.Empty;
    // belt4_itemType = ItemType.Empty;
    // belt5_itemType = ItemType.Empty;
    // belt6_itemType = ItemType.Empty;
    // belt1_quantity = 0;
    // belt2_quantity = 0;
    // belt3_quantity = 0;
    // belt4_quantity = 0;
    // belt5_quantity = 0;
    // belt6_quantity = 0;
    // inventoryDirty = true;
  }

  // static bool removeOnEmpty(int itemType) =>
  //     itemType == ItemType.Weapon_Thrown_Grenade ||
  //     ItemType.isTypeConsumable(itemType)
  // ;

  int? getEmptyInventoryIndex(){
    for (var i = 0; i < inventory.length; i++){
      if (inventory[i] != GameObjectType.Nothing) continue;
      return i;
    }
    return null;
  }


  bool isValidInventoryIndex(int? index) => true;

  // bool isValidInventoryIndex(int? index) =>
  //     index != null &&
  //         index >= 0 &&
  //         (
  //             ItemType.isTypeEquipped(index) ||
  //                 ItemType.isIndexBelt(index) ||
  //                 index < inventory.length
  //         );

  bool itemTypeCanBeAssignedToIndex({
    required int itemType,
    required int index,
  }) {
    return true;
    // if (!isValidInventoryIndex(index)) return false;
    // if (itemType == ItemType.Empty) return true;
    // if (index < inventory.length) return true;
    // if (ItemType.isIndexBelt(index)) return true;
    //
    // if (index == ItemType.Equipped_Head){
    //   return ItemType.isTypeHead(itemType);
    // }
    // if (index == ItemType.Equipped_Body){
    //   return ItemType.isTypeBody(itemType);
    // }
    // if (index == ItemType.Equipped_Legs){
    //   return ItemType.isTypeLegs(itemType);
    // }
    // if (index == ItemType.Equipped_Weapon){
    //   return ItemType.isTypeWeapon(itemType);
    // }
    // return false;
  }

  void endInteraction(){
    if (interactMode == InteractMode.None) return;
    if (storeItems.isNotEmpty) {
      storeItems = [];
      writeStoreItems();
    }
    if (npcOptions.isNotEmpty) {
      npcOptions.clear();
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

  void writeNpcTalk({required String text, Map<String, Function>? options}){
    interactMode = InteractMode.Talking;
    this.npcOptions = options ?? {'Goodbye' : endInteraction};
    writeByte(ServerResponse.Npc_Talk);
    writeString(text);
    writeByte(this.npcOptions.length);
    for (final option in this.npcOptions.keys){
      writeString(option);
    }
  }

  void writeStoreItems(){
    writeByte(ServerResponse.Store_Items);
    writeUInt16(storeItems.length);
    storeItems.forEach(writeUInt16);
  }

  void setStoreItems(List<int> values){
    if (values.isNotEmpty){
      interactMode = InteractMode.Trading;
    }
    this.storeItems = values;
    writeStoreItems();
  }

  void writePlayerInteractMode() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Interact_Mode);
    writeByte(interactMode);
  }

  void dropItemType({required int itemType, required int quantity}){
    // if (itemType == ItemType.Empty) return;
    // game.spawnGameObjectItemAtPosition(
    //   position: this,
    //   type: itemType,
    //   quantity: quantity,
    // );
    // writePlayerEvent(PlayerEvent.Item_Dropped);
  }
}
