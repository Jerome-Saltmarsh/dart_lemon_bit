import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';

class LemonEngineEvents {
  void onKeyboardEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      Engine.keyPressedHandlers[event.logicalKey]?.call();
      return;
    }
    if (event is RawKeyUpEvent) {
      Engine.keyReleasedHandlers[event.logicalKey]?.call();
    }
  }
}

