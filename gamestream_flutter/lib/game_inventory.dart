
import 'package:flutter/foundation.dart';

import 'library.dart';

class GameInventory {

   static var reads = Watch(0, onChanged: (int reads) {
      GameInventoryUI.itemTypeHover.value = ItemType.Empty;
   });

   static void updateUI(){
      reads.value++;

   }
}