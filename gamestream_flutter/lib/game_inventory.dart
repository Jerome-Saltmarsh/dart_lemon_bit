
import 'package:flutter/foundation.dart';

import 'library.dart';

class GameInventory {
   static var reads = Watch(0, onChanged: (int reads) {
      GameInventoryUI.itemTypeHover.value = ItemType.Empty;
      canvasDrawNotifier.value++;
   });

   static final canvasDrawNotifier = ValueNotifier(0);
}