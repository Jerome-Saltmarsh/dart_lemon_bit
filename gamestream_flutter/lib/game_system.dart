
import 'dart:async';

import 'package:gamestream_flutter/game_images.dart';
import 'package:gamestream_flutter/game_network.dart';
import 'package:lemon_engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'website/website.dart';

class GameSystem {

    static Future init(SharedPreferences sharedPreferences) async {
      print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");
      await GameImages.loadImages();
      Engine.cursorType.value = CursorType.Basic;
      Engine.onDrawCanvas = Website.renderCanvas;
    }

  static void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    Website.error.value = error.toString();
  }

  static void disconnect() => GameNetwork.disconnect();
}