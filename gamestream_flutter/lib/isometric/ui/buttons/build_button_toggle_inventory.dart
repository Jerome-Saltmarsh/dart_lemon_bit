import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';


Widget buildButtonToggleInventory() {
  return onPressed(
    hint: "Inventory (I)",
    action: GameState.actionToggleInventoryVisible,
    child: WatchBuilder(GameState.inventoryOpen, (bool inventoryVisible) {
      if (inventoryVisible){
        return text("Inventory");
      }
      return text("Inventory");
    }),
  );
}