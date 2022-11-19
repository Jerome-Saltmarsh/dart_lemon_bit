

import 'package:gamestream_flutter/library.dart';

class ServerQuery {
  static bool playerCanAffordToBuy(int itemType) =>
    ItemType.getBuyPrice(itemType) <= ServerState.playerGold.value;

  static int getItemQuantity(int itemType) {
     var total = 0;
     for (var i = 0; i < ServerState.inventory.length; i++){
        if (ServerState.inventory[i] != itemType) continue;
        total += ServerState.inventoryQuantity[i];
     }
     return total;
  }

  static int getItemTypeConsumesRemaining(int itemType) {
    final consumeAmount = ItemType.getConsumeAmount(itemType);
    if (consumeAmount <= 0) return 0;
    return getItemQuantity(ItemType.getConsumeType(itemType)) ~/ consumeAmount;
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
}