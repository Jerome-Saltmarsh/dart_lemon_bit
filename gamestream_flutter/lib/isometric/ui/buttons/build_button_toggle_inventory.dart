import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/isometric/watches/inventory_visible.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../actions/action_toggle_inventory.dart';

Widget buildButtonToggleInventory() {
  return onPressed(
    hint: "Inventory (I)",
    action: actionToggleInventoryVisible,
    child: WatchBuilder(inventoryVisible, (bool inventoryVisible) {
      if (inventoryVisible){
        return text("Inventory");
      }
      return text("Inventory");
    }),
  );
}