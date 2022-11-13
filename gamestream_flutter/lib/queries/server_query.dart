

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

  static int getItemTypeAtInventoryIndex(int index){
    if (index == ItemType.Equipped_Weapon)
      return GamePlayer.weapon.value;

    if (index == ItemType.Equipped_Head)
      return GamePlayer.head.value;

    if (index == ItemType.Equipped_Body)
      return GamePlayer.body.value;

    if (index == ItemType.Equipped_Legs)
      return GamePlayer.legs.value;

    if (index >= ServerState.inventory.length){
      throw Exception("ServerQuery.getItemTypeWatchAtInventoryIndex($index) index >= ServerState.inventory.length");
    }
    if (index < 0){
      throw Exception("ServerQuery.getItemTypeWatchAtInventoryIndex($index) index < 0");
    }
    return ServerState.inventory[index];
  }
}