import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/library.dart';


Widget buildButtonToggleInventory() {
  return onPressed(
    hint: "Inventory (I)",
    action: gsEngine.network.sendClientRequestInventoryToggle,
    child: text("Inventory"),
  );
}