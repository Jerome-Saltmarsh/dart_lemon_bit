

import 'package:gamestream_flutter/library.dart';

class ServerQuery {

  static int getWatchBeltItemTypeIndex(Watch<int> watchBelt){
     if (watchBelt == ServerState.playerBelt1_ItemType) return ItemType.Belt_1;
     if (watchBelt == ServerState.playerBelt2_ItemType) return ItemType.Belt_2;
     if (watchBelt == ServerState.playerBelt3_ItemType) return ItemType.Belt_3;
     if (watchBelt == ServerState.playerBelt4_ItemType) return ItemType.Belt_4;
     if (watchBelt == ServerState.playerBelt5_ItemType) return ItemType.Belt_5;
     if (watchBelt == ServerState.playerBelt6_ItemType) return ItemType.Belt_6;
     throw Exception('ServerQuery.getWatchBeltIndex($watchBelt)');
  }

  static Watch<int> getWatchBeltTypeWatchQuantity(Watch<int> watchBelt){
    if (watchBelt == ServerState.playerBelt1_ItemType) return ServerState.playerBelt1_Quantity;
    if (watchBelt == ServerState.playerBelt2_ItemType) return ServerState.playerBelt2_Quantity;
    if (watchBelt == ServerState.playerBelt3_ItemType) return ServerState.playerBelt3_Quantity;
    if (watchBelt == ServerState.playerBelt4_ItemType) return ServerState.playerBelt4_Quantity;
    if (watchBelt == ServerState.playerBelt5_ItemType) return ServerState.playerBelt5_Quantity;
    if (watchBelt == ServerState.playerBelt6_ItemType) return ServerState.playerBelt6_Quantity;
    throw Exception('ServerQuery.getWatchBeltQuantity($watchBelt)');
  }

  static int getItemTypeConsumesRemaining(int itemType) {
    final consumeAmount = ItemType.getConsumeAmount(itemType);
    if (consumeAmount <= 0) return 0;
    return countItemTypeQuantityInPlayerPossession(ItemType.getConsumeType(itemType)) ~/ consumeAmount;
  }

  static int mapWatchBeltTypeToItemType(Watch<int> watchBeltType){
     if (watchBeltType == ServerState.playerBelt1_ItemType) return ItemType.Belt_1;
     if (watchBeltType == ServerState.playerBelt2_ItemType) return ItemType.Belt_2;
     if (watchBeltType == ServerState.playerBelt3_ItemType) return ItemType.Belt_3;
     if (watchBeltType == ServerState.playerBelt4_ItemType) return ItemType.Belt_4;
     if (watchBeltType == ServerState.playerBelt5_ItemType) return ItemType.Belt_5;
     if (watchBeltType == ServerState.playerBelt6_ItemType) return ItemType.Belt_6;
     throw Exception('ServerQuery.mapWatchBeltTypeToItemType($watchBeltType)');
  }

  static int getItemQuantityAtIndex(int index){
    assert (index >= 0);
    if (index < ServerState.inventory.length)
      return ServerState.inventoryQuantity[index];
    if (index == ItemType.Belt_1)
      return ServerState.playerBelt1_Quantity.value;
    if (index == ItemType.Belt_2)
      return ServerState.playerBelt2_Quantity.value;
    if (index == ItemType.Belt_3)
      return ServerState.playerBelt3_Quantity.value;
    if (index == ItemType.Belt_4)
      return ServerState.playerBelt4_Quantity.value;
    if (index == ItemType.Belt_5)
      return ServerState.playerBelt5_Quantity.value;
    if (index == ItemType.Belt_6)
      return ServerState.playerBelt6_Quantity.value;

    throw Exception('ServerQuery.getItemQuantityAtIndex($index)');
  }

  static int getItemTypeAtInventoryIndex(int index){
    if (index == ItemType.Equipped_Weapon)
      return GamePlayer.weapon.value;

    if (index == ItemType.Equipped_Head)
      return GamePlayer.head.value;

    if (index == ItemType.Equipped_Body)
      return GamePlayer.body.value;

    if (index == ItemType.Equipped_Legs)
      return GamePlayer.legs.value;

    if (index == ItemType.Belt_1){
      return ServerState.playerBelt1_ItemType.value;
    }
    if (index == ItemType.Belt_2){
      return ServerState.playerBelt2_ItemType.value;
    }
    if (index == ItemType.Belt_3){
      return ServerState.playerBelt3_ItemType.value;
    }
    if (index == ItemType.Belt_4){
      return ServerState.playerBelt4_ItemType.value;
    }
    if (index == ItemType.Belt_5){
      return ServerState.playerBelt5_ItemType.value;
    }
    if (index == ItemType.Belt_6){
      return ServerState.playerBelt6_ItemType.value;
    }
    if (index >= ServerState.inventory.length){
      throw Exception("ServerQuery.getItemTypeAtInventoryIndex($index) index >= ServerState.inventory.length");
    }
    if (index < 0){
      throw Exception("ServerQuery.getItemTypeAtInventoryIndex($index) index < 0");
    }
    return ServerState.inventory[index];
  }

  static int countItemTypeQuantityInPlayerPossession(int itemType){
     var total = 0;
     for (var i = 0; i < ServerState.inventory.length; i++){
         if (ServerState.inventory[i] != itemType) continue;
         total += ServerState.inventoryQuantity[i];
     }
     if (ServerState.playerBelt1_ItemType.value == itemType) {
         total += ServerState.playerBelt1_Quantity.value;
     }
     if (ServerState.playerBelt2_ItemType.value == itemType) {
       total += ServerState.playerBelt2_Quantity.value;
     }
     if (ServerState.playerBelt3_ItemType.value == itemType) {
       total += ServerState.playerBelt3_Quantity.value;
     }
     if (ServerState.playerBelt4_ItemType.value == itemType) {
       total += ServerState.playerBelt4_Quantity.value;
     }
     if (ServerState.playerBelt5_ItemType.value == itemType) {
       total += ServerState.playerBelt5_Quantity.value;
     }
     if (ServerState.playerBelt6_ItemType.value == itemType) {
       total += ServerState.playerBelt6_Quantity.value;
     }
     return total;
  }

  static int getEquippedWeaponType() =>
      getItemTypeAtInventoryIndex(ServerState.equippedWeaponIndex.value);

  static int getEquippedItemType(int itemType) =>
      ItemType.isTypeWeapon(itemType) ? GamePlayer.weapon.value :
      ItemType.isTypeHead(itemType)   ? GamePlayer.head.value   :
      ItemType.isTypeBody(itemType)   ? GamePlayer.body.value   :
      ItemType.isTypeLegs(itemType)   ? GamePlayer.legs.value   :
      ItemType.Empty;
}