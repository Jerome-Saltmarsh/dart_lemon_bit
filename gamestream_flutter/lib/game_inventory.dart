
import 'package:flutter/foundation.dart';

import 'library.dart';

class GameInventory {
   static const Size = 32.0;

   static var reads = Watch(0, onChanged: (int reads) {
      canvasDrawNotifier.value++;
   });
   static var total = 0;
   static var index = Uint8List(1000);
   static var itemType = Uint8List(1000);
   static var itemSubType = Uint8List(1000);
   static final canvasDrawNotifier = ValueNotifier(0);
}