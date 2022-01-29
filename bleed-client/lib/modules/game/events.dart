

import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';


class GameEvents {
  void register(){
    print("modules.game.events.register()");
    engine.callbacks.onLeftClicked = performPrimaryAction;
    engine.callbacks.onPanStarted = performPrimaryAction;
    engine.callbacks.onLongLeftClicked = performPrimaryAction;
    modules.isometric.events.register();
    registerPlayKeyboardHandler();
    game.player.characterType.onChanged(_onPlayerCharacterTypeChanged);
  }

  void _onPlayerCharacterTypeChanged(CharacterType characterType){
    print("events.onCharacterTypeChanged($characterType)");
    if (characterType == CharacterType.Human){
      engine.state.cursorType.value = CursorType.Precise;
    }else{
      engine.state.cursorType.value = CursorType.Basic;
    }
  }
}