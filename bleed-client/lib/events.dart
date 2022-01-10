
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/functions/cameraCenterPlayer.dart';
import 'package:bleed_client/functions/removeGeneratedEnvironmentObjects.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/logic.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/services/userService.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/ui/ui.dart';
import 'package:bleed_client/watches/compiledGame.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/material.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/functions/fullscreen_enter.dart';
import 'package:lemon_engine/functions/fullscreen_exit.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';

import 'common/GameType.dart';
import 'enums/Region.dart';
import 'functions/clearState.dart';

class Events {

  Events() {
    print("Events()");
    webSocket.connection.onChanged(_onConnectionChanged);
    game.type.onChanged(_onGameTypeChanged);
    game.region.onChanged(_onServerTypeChanged);
    game.player.uuid.onChanged(_onPlayerUuidChanged);
    game.player.alive.onChanged(_onPlayerAliveChanged);
    game.status.onChanged(_onGameStatusChanged);
    game.mode.onChanged(_onGameModeChanged);
    game.subscription.onChanged(_onSubscriptionChanged);
    mouseEvents.onLeftClicked.onChanged(_onMouseLeftClickedChanged);
    authentication.onChanged(_onAuthenticationChanged);
    sub(_onGameError);
  }

  void _onSubscriptionChanged(DateTime? value) {
    print("events.onSubscriptionChanged($value)");
    if (value == null) {
      storage.remove('subscription');
      return;
    }
    storage.put('subscription', value);
    if (authenticated) {
      final flagName = 'subscription_dialog_shown_${authentication.value!.userId}';
      if (!storage.contains(flagName)) {
        storage.put(flagName, 'true');
        game.dialog.value = Dialogs.Subscription_Successful;
      }
    }
  }

  Future _onGameError(GameError error) async {
    print(error);

    switch (error) {
      case GameError.PlayerId_Required:
        clearState();
        webSocket.disconnect();
        game.dialog.value = Dialogs.Login;
        return;
      case GameError.Subscription_Required:
        game.dialog.value = Dialogs.Subscription_Required;
        return;
      case GameError.GameNotFound:
        clearState();
        webSocket.disconnect();
        return;
      case GameError.InvalidArguments:
        if (compiledGame.length > 4) {
          String message = compiledGame.substring(4, compiledGame.length);
          print('Invalid Arguments: $message');
        }
        game.dialog.value = Dialogs.Invalid_Arguments;
        return;
      default:
        break;
    }
    if (error == GameError.PlayerNotFound) {
      clearState();
      webSocket.disconnect();
    }
  }

  void _onAuthenticationChanged(Authentication? value) async {
    print("events._onAuthorizationChanged()");
    if (value == null) {
      game.subscription.value = null;
      storage.forgetAuthorization();
    } else {
      storage.rememberAuthorization(value);
      updateUserSubscription(value.userId);
    }
    game.dialog.value = Dialogs.Games;
  }

  void _onMouseLeftClickedChanged(Function? function){
     if (function == null){
       print("mouseEvents.onLeftClicked.onChanged(null)");
     }else{
       print("mouseEvents.onLeftClicked.onChanged($function)");
     }
  }

  void _onGameTypeChanged(GameType type) {
    print('events.onGameTypeChanged($type)');
    logic.clearSession();
    camera.x = 0;
    camera.y = 0;
    zoom = 1;
    switch (type) {
      case GameType.None:
        break;
      // case GameType.CUBE3D:
      //   if (game.type.value == GameType.CUBE3D){
      //     requestPointerLock();
      //     overrideBuilder.value = (BuildContext context){
      //       return buildCube3D();
      //     };
      //     Timer.periodic(Duration(milliseconds: 50), (timer) {
      //       cubeFrame.value++;
      //     });
      //   }
      //   break;
      default:
        // connectToWebSocketServer(game.region.value, type);
        break;
    }
  }

  void _onServerTypeChanged(Region serverType) {
    print('events.onServerTypeChanged($serverType)');
    storage.saveServerType(serverType);
  }

  void _onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch(connection){
      case Connection.Connected:
        ui.drawCanvasAfterUpdate = false;
        sendRequestJoinGame(game.type.value, playerId: authentication.value?.userId);
        mouseEvents.onLeftClicked.value = performPrimaryAction;
        mouseEvents.onPanStarted.value = performPrimaryAction;
        mouseEvents.onLongLeftClicked.value = performPrimaryAction;
        fullScreenEnter();
        break;
      case Connection.Done:
        fullScreenExit();
        logic.clearSession();
        game.status.value = GameStatus.None;
        mouseEvents.onLeftClicked.value = null;
        mouseEvents.onPanStarted.value = null;
        mouseEvents.onLongLeftClicked.value = null;
        ui.drawCanvasAfterUpdate = true;
        break;
      default:
        break;
    }
  }

  void _onPlayerUuidChanged(String uuid) {
    print("events.onPlayerUuidChanged($uuid)");
    if (uuid.isNotEmpty) {
      cameraCenterPlayer();
    }
  }

  void _onPlayerAliveChanged(bool value) {
    print("events.onPlayerAliveChanged($value)");
    if (value) {
      cameraCenterPlayer();
    }
  }

  void _onGameStatusChanged(GameStatus value){
    print('events.onGameStatusChanged($value)');
    switch(value){
      case GameStatus.In_Progress:
        // ui.backgroundColor.value = colours.black;
        fullScreenEnter();
        break;
      default:
        // ui.backgroundColor.value = Colors.black;
        fullScreenExit();
        break;
    }
  }

  void _onGameModeChanged(Mode mode){
    print("_onGameModeChanged($mode)");
    if (mode == Mode.Edit) {
      // onLeftClicked.stream.listen(editor.onMouseLeftClicked);
      removeGeneratedEnvironmentObjects();
      deregisterPlayKeyboardHandler();
      // registerEditorKeyboardListener();
      editor.init();
      game.totalZombies.value = 0;
      game.totalProjectiles = 0;
      game.totalNpcs = 0;
      game.totalHumans = 0;
      game.zombies.clear();
      game.projectiles.clear();
      game.interactableNpcs.clear();
      game.humans.clear();
      game.particles.clear();
      timeInSeconds.value = 60 * 60 * 10;
    }
    redrawCanvas();
  }
}

void updateUserSubscription(String userId) async {
  print("updateUserSubscription()");
  game.signingIn.value = true;
  game.subscription.value = await getUserSubscriptionExpiration(userId).catchError((error){
    print(error);
    return null;
  });
  game.signingIn.value = false;
}