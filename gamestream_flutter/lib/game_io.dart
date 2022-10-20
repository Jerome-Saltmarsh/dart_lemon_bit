
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game_network.dart';
import 'package:lemon_engine/engine.dart';

class GameIO {

  static bool get keyPressedSpace => Engine.keyPressed(LogicalKeyboardKey.space);

  static void initGameListeners(){
      Engine.onPanStart = onPanStart;
      Engine.onPanUpdate = onPanUpdate;
      Engine.onPanEnd = onPanEnd;
      Engine.onTapDown = onTapDown;
      Engine.onLongPressDown = onLongPressDown;
      Engine.onSecondaryTapDown = onSecondaryTapDown;
  }

  static void onSecondaryTapDown(TapDownDetails details){
     print("onSecondaryTapDown()");
  }

  static void onLongPressDown(LongPressDownDetails details){
    print("onLongPressDown()");
  }

  static void onPanStart(DragStartDetails details) {
     print("onPanStart()");
  }

  static void onPanUpdate(DragUpdateDetails details) {
    print("onPanUpdate()");
    // GameNetwork.
  }

  static void onPanEnd(DragEndDetails details){
    print("onPanEnd()");
  }

  static void onTapDown(TapDownDetails details){
    print('onTapDown()');
  }
}