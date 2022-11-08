
import 'package:flutter/foundation.dart';

import 'library.dart';

class GameInventory {
   static var reads = Watch(0, onChanged: (int reads) {
      canvasDrawNotifier.value++;
   });

   static final canvasDrawNotifier = ValueNotifier(0);
}