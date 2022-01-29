

import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules/game/actions.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';


class GameEvents {

  final GameActions actions;

  GameEvents(this.actions);

  void register(){
    print("modules.game.events.register()");
    engine.callbacks.onLeftClicked = performPrimaryAction;
    engine.callbacks.onPanStarted = performPrimaryAction;
    engine.callbacks.onLongLeftClicked = performPrimaryAction;
    modules.isometric.events.register();
    registerPlayKeyboardHandler();
    game.player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    game.type.onChanged(_onGameTypeChanged);
    game.player.uuid.onChanged(_onPlayerUuidChanged);
    game.player.alive.onChanged(_onPlayerAliveChanged);
    game.status.onChanged(_onGameStatusChanged);
    sub(_onGameError);
  }

  void _onPlayerAliveChanged(bool value) {
    print("events.onPlayerAliveChanged($value)");
    if (value) {
      actions.cameraCenterPlayer();
    }
  }


  Future _onGameError(GameError error) async {
    print("events.onGameEvent('$error'");
    switch (error) {
      case GameError.PlayerId_Required:
        core.actions.disconnect();
        website.actions.showDialogLogin();
        return;
      case GameError.Subscription_Required:
        core.actions.disconnect();
        website.actions.showDialogSubscriptionRequired();
        return;
      case GameError.GameNotFound:
        core.actions.disconnect();
        core.actions.setError("game could not be found");
        return;
      case GameError.InvalidArguments:
        core.actions.disconnect();
        if (event.length > 4) {
          String message = event.substring(4, event.length);
          core.actions.setError("Invalid Arguments: $message");
          return;
        }
        core.actions.setError("game could not be found");
        return;
      case GameError.PlayerNotFound:
        core.actions.disconnect();
        core.actions.setError("Player could not be found");
        break;
      default:
        break;
    }
  }

  void _onPlayerCharacterTypeChanged(CharacterType characterType){
    print("events.onCharacterTypeChanged($characterType)");
    if (characterType == CharacterType.Human){
      engine.state.cursorType.value = CursorType.Precise;
    }else{
      engine.state.cursorType.value = CursorType.Basic;
    }
  }

  void _onGameTypeChanged(GameType type) {
    print('events.onGameTypeChanged($type)');
    core.actions.clearSession();
    engine.state.camera.x = 0;
    engine.state.camera.y = 0;
    engine.state.zoom = 1;
  }

  void _onPlayerUuidChanged(String uuid) {
    print("events.onPlayerUuidChanged($uuid)");
    if (uuid.isNotEmpty) {
      actions.cameraCenterPlayer();
    }
  }

  void _onGameStatusChanged(GameStatus value){
    print('events.onGameStatusChanged($value)');
    switch(value){
      case GameStatus.In_Progress:
      // engine.state.drawCanvas = modules.game.render;
        engine.actions.fullScreenEnter();
        break;
      default:
        engine.state.drawCanvas = null;
        engine.actions.fullScreenExit();
        break;
    }
  }
}