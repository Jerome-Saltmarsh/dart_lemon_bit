import 'dart:async';

import 'package:gamestream_flutter/game_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'library.dart';

class GameSystem {

  static Future init(SharedPreferences sharedPreferences) async {
    print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");

    final visitDateTimeString = sharedPreferences.getString('visit-datetime');
    if (visitDateTimeString != null) {
      final visitDateTime = DateTime.parse(visitDateTimeString);
      final durationSinceLastVisit = DateTime.now().difference(visitDateTime);
      print("duration since last visit: ${durationSinceLastVisit.inSeconds} seconds");
      WebsiteActions.saveVisitDateTime();
      if (durationSinceLastVisit.inSeconds > 45){
        WebsiteActions.checkForLatestVersion();
        return;
      }
    }

    print("time zone: ${GameUtils.detectConnectionRegion()}");
    Engine.onScreenSizeChanged = onScreenSizeChanged;
    Engine.deviceType.onChanged(onDeviceTypeChanged);
    GameImages.loadImages();
    Engine.cursorType.value = CursorType.Basic;
    // Engine.onDrawCanvas = GameWebsite.renderCanvas;
    GameIO.addListeners();
    GameIO.detectInputMode();

    if (Engine.isLocalHost) {
      GameWebsite.region.value = ConnectionRegion.LocalHost;
    } else {
      GameWebsite.region.value = GameUtils.detectConnectionRegion();
    }

    GameWebsite.errorMessageEnabled.value = true;

    final visitCount = sharedPreferences.getInt('visit-count');
    if (visitCount == null){
      sharedPreferences.putAny('visit-count', 1);
      GameWebsite.visitCount.value = 1;
      // GameNetwork.connectToGameDarkAge();
    } else {
      sharedPreferences.putAny('visit-count', visitCount + 1);
      GameWebsite.visitCount.value = visitCount + 1;

      final cachedVersion = sharedPreferences.getString('version');


      if (cachedVersion != null){
         if (version != cachedVersion){
            print("New version detected (previous: $cachedVersion, latest: $version)");
         }
      }
    }
    await Future.delayed(const Duration(seconds: 4));
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
      GameEvents.onErrorFullscreenAuto();
      return;
    }
    print(error.toString());
    print(stack);
    WebsiteState.error.value = error.toString();
  }
}
