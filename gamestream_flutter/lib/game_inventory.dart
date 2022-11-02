
import 'package:flutter/foundation.dart';

import 'library.dart';

class GameInventory {
   static var reads = Watch(0, onChanged: (int reads) {
      canvasDrawNotifier.value++;
   });
   static var total = 0;
   static var x = Uint8List(1000);
   static var y = Uint8List(1000);
   static var itemType = Uint8List(1000);
   static var itemSubType = Uint8List(1000);
   static final canvasDrawNotifier = ValueNotifier(0);
}