
import 'package:flutter/foundation.dart';

import 'library.dart';

class GameInventory {
   static const Size = 32.0;

   static var reads = Watch(0, onChanged: (int reads) {
      canvasDrawNotifier.value++;
   });

   static final canvasDrawNotifier = ValueNotifier(0);
   static var items = Uint16List(0);
}