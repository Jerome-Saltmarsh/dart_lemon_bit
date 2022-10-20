import 'dart:async';

import 'package:lemon_engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_library.dart';
import 'game_website.dart';

class GameSystem {

  static Future init(SharedPreferences sharedPreferences) async {
    print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");
    await GameImages.loadImages();
    Engine.cursorType.value = CursorType.Basic;
    Engine.onDrawCanvas = GameWebsite.renderCanvas;
    GameIO.initGameListeners();
  }

  static void onError(Object error, StackTrace stack) {
    print(error.toString());
    print(stack);
    GameWebsite.error.value = error.toString();
  }
}
