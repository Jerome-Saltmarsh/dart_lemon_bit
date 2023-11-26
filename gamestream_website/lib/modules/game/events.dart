import 'dart:async';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';



class GameEvents {

  final GameActions actions;
  final GameState state;

  Timer? updateTimer;

  GameEvents(this.actions, this.state);

  void register(){
    gameType.onChanged(_onGameTypeChanged);
    player.alive.onChanged(_onPlayerAliveChanged);
    player.state.onChanged(onPlayerCharacterStateChanged);
    messageBoxVisible.onChanged(onTextModeChanged);
    sub(_onGameError);

    updateTimer = Timer.periodic(Duration(milliseconds: 1000.0 ~/ 30.0), (timer) {
      engine.updateEngine();
    });
  }

  void deregister(){
    updateTimer?.cancel();
  }

  void onTextModeChanged(bool textMode) {
    if (textMode) {
      state.textFieldMessage.requestFocus();
      return;
    }
    sendRequestSpeak(state.textEditingControllerMessage.text);
    state.textFieldMessage.unfocus();
    state.textEditingControllerMessage.text = "";
  }

  // TODO Remove
  void onPlayerCharacterStateChanged(int characterState){
    player.alive.value = characterState != CharacterState.Dead;
  }

  void _onPlayerAliveChanged(bool value) {
    print("events.onPlayerAliveChanged($value)");
    if (value) {
      // actions.cameraCenterPlayer();
      cameraCenterOnPlayer();
    }
  }

  Future _onGameError(GameError error) async {
    print("events.onGameEvent('$error')");
    switch (error) {
      case GameError.Insufficient_Resources:
        audio.error();
        break;
      case GameError.PlayerId_Required:
        core.actions.disconnect();
        website.actions.showDialogLogin();
        core.actions.setError("Account is null");
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
        // if (event.length > 4) {
        //   String message = event.substring(4, event.length);
        //   core.actions.setError("Invalid Arguments: $message");
        //   return;
        // }
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

  void _onGameTypeChanged(GameType? type) {
    engine.camera.x = 0;
    engine.camera.y = 0;
    engine.zoom = 1;
  }
}