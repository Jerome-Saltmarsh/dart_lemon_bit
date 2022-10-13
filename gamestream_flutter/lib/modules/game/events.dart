import 'dart:async';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_dispatch/instance.dart';

class GameEvents {

  void register(){
    player.alive.onChanged(_onPlayerAliveChanged);
    player.state.onChanged(onPlayerCharacterStateChanged);
    sub(_onGameError);
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
}