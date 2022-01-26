

import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules.dart';
import 'package:lemon_engine/engine.dart';


class GameEvents {
  void register(){
    print("modules.game.events.register()");
    engine.callbacks.onLeftClicked = performPrimaryAction;
    engine.callbacks.onPanStarted = performPrimaryAction;
    engine.callbacks.onLongLeftClicked = performPrimaryAction;
    modules.isometric.events.register();
    registerPlayKeyboardHandler();
  }
}