import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildButtonToggleInventory() {
  return onPressed(
    hint: "Inventory (I)",
    action: GameState.actionToggleInventoryVisible,
    child: WatchBuilder(GameState.inventoryVisible, (bool inventoryVisible) {
      if (inventoryVisible){
        return text("Inventory");
      }
      return text("Inventory");
    }),
  );
}