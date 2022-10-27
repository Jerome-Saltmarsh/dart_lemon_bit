import 'dart:async';

import 'package:gamestream_flutter/game_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'library.dart';

class GameSystem {

  static Future init(SharedPreferences sharedPreferences) async {
    print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");
    print("time zone: ${GameUtils.detectConnectionRegion()}");

    Engine.onScreenSizeChanged = onScreenSizeChanged;
    Engine.deviceType.onChanged(onDeviceTypeChanged);
    await GameImages.loadImages();
    Engine.cursorType.value = CursorType.Basic;
    Engine.onDrawCanvas = GameWebsite.renderCanvas;
    GameIO.addListeners();
    GameIO.detectInputMode();
    GameWebsite.region.value = GameUtils.detectConnectionRegion();
  }

  static void onDeviceTypeChanged(int deviceType){
    GameIO.detectInputMode();
  }

  static void onScreenSizeChanged(
      double previousWidth,
      double previousHeight,
      double newWidth,
      double newHeight,
  ) => GameIO.detectInputMode();

  static void onError(Object error, StackTrace stack) {
    print(error.toString());
    print(stack);
    GameWebsite.error.value = error.toString();
  }
}
