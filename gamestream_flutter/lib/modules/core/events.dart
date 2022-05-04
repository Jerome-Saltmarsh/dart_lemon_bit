

import 'package:bleed_common/ClientRequest.dart';
import 'package:bleed_common/GameStatus.dart';
import 'package:bleed_common/GameType.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/toString.dart';
import 'package:gamestream_flutter/webSocket.dart';
import 'package:lemon_dispatch/instance.dart';
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
    engine.drawCanvas.onChanged(onDrawCanvasChanged);
  }

  void _onGameStatusChanged(GameStatus value){
    print('events.onGameStatusChanged(value: $value)');
    audio.stopMusic();

    switch(value){
      case GameStatus.In_Progress:
        engine.drawCanvas.value = modules.game.render.render;
        if (state.statusPrevious.value == GameStatus.Awaiting_Players){
          audio.gong();
        }
        engine.drawCanvasAfterUpdate = false;
        engine.fullScreenEnter();
        break;
      default:
        engine.fullScreenExit();
        break;
    }
    core.state.statusPrevious.value = value;
  }

  void onDrawCanvasChanged(DrawCanvas? method){
    print("core.events.onDrawCanvasChanged($method)");
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

    switch(mode){

      case Mode.Website:
        engine.drawCanvas.value = null;
        engine.drawCanvasAfterUpdate = true;
        engine.keyPressedHandlers = {};
        break;

      case Mode.Player:
        engine.drawCanvas.value = modules.game.render.render;
        engine.drawForeground.value = modules.game.render.renderForeground;
        engine.update = modules.game.update.update;
        engine.drawCanvasAfterUpdate = true;
        modules.isometric.events.register();
        modules.game.events.register();
        engine.registerZoomCameraOnMouseScroll();
        engine.keyPressedHandlers = modules.game.map.keyPressedHandlers;
        break;

      case Mode.Editor:
        modules.isometric.events.register();
        engine.drawCanvas.value = editor.render.render;
        engine.drawCanvasAfterUpdate = true;
        editor.events.onActivated();
        isometric.removeGeneratedEnvironmentObjects();
        game.totalZombies.value = 0;
        game.totalProjectiles = 0;
        game.totalNpcs = 0;
        engine.registerZoomCameraOnMouseScroll();
        isometric.cameraCenterMap();
        break;
    }

    engine.redrawCanvas();
  }


  void onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch (connection) {

      case Connection.Connected:
        sendClientRequest(ClientRequest.Scene);
        core.state.mode.value = Mode.Player;
        if (game.type.value == GameType.Custom){
          final account = core.state.account.value;
          if (account == null){
            core.actions.setError("Account required to play custom map");
            return;
          }
          final mapName = game.customGameName;
          sendRequestJoinCustomGame(mapName: mapName, playerId: account.userId);
        }else{
          sendRequestJoinGame(game.type.value);
        }
        break;

      case Connection.Done:
        engine.update = null;
        core.state.mode.value = Mode.Website;
        engine.fullScreenExit();
        core.actions.clearState();
        engine.clearCallbacks();
        engine.drawCanvasAfterUpdate = true;
        engine.cursorType.value = CursorType.Basic;
        core.state.status.value = GameStatus.None;
        game.type.value = GameType.None;
        break;
      default:
        break;
    }
  }
}