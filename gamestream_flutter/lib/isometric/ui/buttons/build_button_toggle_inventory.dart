import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';


Widget buildButtonToggleInventory() {
  return onPressed(
    hint: "Inventory (I)",
    action: GameState.actionToggleInventoryVisible,
    child: text("Inventory"),
  );
}