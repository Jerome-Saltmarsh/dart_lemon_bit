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
    // GameWebsite.errorMessageEnabled.value = Engine.isLocalHost;
    GameWebsite.errorMessageEnabled.value = true;
    Engine.joystickMaxDistance = 150;

    final visitCount = sharedPreferences.getInt('visit-count');
    if (visitCount == null){
      sharedPreferences.putAny('visit-count', 1);
      GameWebsite.visitCount.value = 1;
      GameNetwork.connectToGameSkirmish();
    } else {
      sharedPreferences.putAny('visit-count', visitCount + 1);
      GameWebsite.visitCount.value = visitCount + 1;
    }
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
    if (error.toString().contains('NotAllowedError')){
      // https://developer.chrome.com/blog/autoplay/
      // This error appears when the game attempts to fullscreen
      // without the user having interacted first
      // TODO dispatch event on fullscreen failed
      return;
    }
    print(error.toString());
    print(stack);
    GameWebsite.error.value = error.toString();
  }
}
