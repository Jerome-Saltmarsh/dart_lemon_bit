

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
}