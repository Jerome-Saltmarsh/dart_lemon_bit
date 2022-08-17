

import 'package:bleed_common/GameStatus.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/events/on_connection_done.dart';
import 'package:gamestream_flutter/isometric_web/register_isometric_web_controls.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/web_socket.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/actions.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';

import 'exceptions.dart';

class CoreEvents {

  late final CoreState state;

  CoreEvents(this.state){
    state.mode.onChanged(onModeChanged);
    state.region.onChanged(_onServerTypeChanged);
    state.account.onChanged(_onAccountChanged);
    state.status.onChanged(_onGameStatusChanged);
    webSocket.connection.onChanged(onConnectionChanged);
    sub(_onLoginException);
  }

  void _onGameStatusChanged(GameStatus value){
    print('events.onGameStatusChanged(value: $value)');

    switch(value) {
      case GameStatus.In_Progress:
        engine.drawCanvas.value = modules.game.render.renderGame;
        engine.drawCanvasAfterUpdate = false;
        fullScreenEnter();
        break;
      default:
        engine.fullScreenExit();
        break;
    }
  }

  Future _onLoginException(LoginException error) async {
    print("onLoginException()");

    core.actions.logout();

    Future.delayed(Duration(seconds: 1), (){
      // game.dialog.value = Dialogs.Login_Error;
      state.error.value = error.cause.toString();
    });
  }


  void _onAccountChanged(Account? account) {
    print("events.onAccountChanged($account)");
    if (account == null) return;
    final flag = 'subscription_status_${account.userId}';
    if (storage.contains(flag)){
      final storedSubscriptionStatusString = storage.get<String>(flag);
      final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
      if (storedSubscriptionStatus != account.subscriptionStatus){
        website.actions.showDialogSubscriptionStatusChanged();
      }
    }
    core.actions.store(flag, enumString(account.subscriptionStatus));
    website.actions.showDialogGames();
  }

  void _onServerTypeChanged(Region serverType) {
    print('core.events.onServerTypeChanged($serverType)');
    storage.saveServerType(serverType);
  }

  void onModeChanged(Mode mode){
    print("core.events.onGameModeChanged($mode)");
    engine.clearCallbacks();
    engine.drawCanvas.value = null;
    engine.drawForeground.value = null;
    engine.drawCanvasAfterUpdate = true;
    engine.update = null;
    engine.keyPressedHandlers = {};
    modules.game.events.deregister();
    isometricWebControlsDeregister();

    switch(mode){

      case Mode.Website:
        engine.drawCanvas.value = null;
        engine.drawCanvasAfterUpdate = true;
        engine.keyPressedHandlers = {};
        break;

      case Mode.Player:
        engine.drawCanvas.value = modules.game.render.renderGame;
        engine.drawForeground.value = modules.game.render.renderForeground;
        engine.update = modules.game.update.update;
        engine.drawCanvasAfterUpdate = true;
        modules.game.events.register();
        engine.registerZoomCameraOnMouseScroll();
        isometricWebControlsRegister();
        break;
    }

    engine.redrawCanvas();
  }


  void onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch (connection) {

      case Connection.Connected:
        core.state.mode.value = Mode.Player;
        // if (game.type.value == GameType.Custom){
        //   final account = core.state.account.value;
        //   if (account == null){
        //     core.actions.setError("Account required to play custom map");
        //     return;
        //   }
        //   final mapName = game.customGameName;
        //   sendRequestJoinCustomGame(mapName: mapName, playerId: account.userId);
        // }else{
        //   sendRequestJoinGame(game.type.value);
        // }
        break;

      case Connection.Done:
        onConnectionDone();
        engine.update = null;
        core.state.mode.value = Mode.Website;
        engine.fullScreenExit();
        core.actions.clearState();
        engine.clearCallbacks();
        engine.drawCanvasAfterUpdate = true;
        engine.cursorType.value = CursorType.Basic;
        core.state.status.value = GameStatus.None;
        gameType.value = null;
        break;
      default:
        break;
    }
  }
}