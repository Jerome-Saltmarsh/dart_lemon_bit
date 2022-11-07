import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';


Widget buildButtonToggleInventory() {
  return onPressed(
    hint: "Inventory (I)",
    action: GameNetwork.sendClientRequestInventoryToggle,
    child: text("Inventory"),
  );
}