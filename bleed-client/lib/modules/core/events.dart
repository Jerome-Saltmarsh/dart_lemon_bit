

import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/core/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/sharedPreferences.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/webSocket.dart';
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
    webSocket.connection.onChanged(onConnectionChanged);
    sub(_onLoginException);
    engine.drawCanvas.onChanged(onDrawCanvasChanged);
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
    core.actions.clearState();

    switch(mode){

      case Mode.Website:
        engine.drawCanvas.value = null;
        engine.redrawCanvas();
        engine.drawCanvasAfterUpdate = false;
        break;

      case Mode.Player:
        engine.drawCanvas.value = modules.game.render.render;
        engine.drawCanvasAfterUpdate = true;
        modules.isometric.events.register();
        modules.game.events.register();
        engine.registerZoomCameraOnMouseScroll();
        engine.keyPressedHandlers = modules.game.map.keyPressedHandlers;
        break;

      case Mode.Editor:
        modules.isometric.events.register();
        editor.actions.newScene();
        engine.drawCanvas.value = editor.render.render;
        engine.drawCanvasAfterUpdate = true;
        editor.events.onActivated();
        isometric.actions.removeGeneratedEnvironmentObjects();
        game.totalZombies.value = 0;
        game.totalProjectiles = 0;
        game.totalNpcs = 0;
        engine.registerZoomCameraOnMouseScroll();
        isometric.actions.cameraCenterMap();
        break;
    }

    engine.redrawCanvas();
  }


  void onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch(connection){
      case Connection.Connected:
        engine.drawCanvas.value = modules.game.render.render;
        core.state.mode.value = Mode.Player;
        if (game.type.value == GameType.Custom){
          final account = core.state.account.value;
          if (account == null){
            core.actions.setError("Account required to play custom map");
            return;
          }
          final mapName = game.customGameName;
          if (mapName == null){
            core.actions.setError("No custom map chosen");
            core.actions.disconnect();
            return;
          }
          sendRequestJoinCustomGame(mapName: mapName, playerId: account.userId);
        }else{
          sendRequestJoinGame(game.type.value, playerId: core.state.account.value?.userId);
        }
        break;
      case Connection.Done:
        core.state.mode.value = Mode.Website;
        engine.fullScreenExit();
        core.actions.clearSession();
        engine.clearCallbacks();
        engine.drawCanvasAfterUpdate = true;
        engine.cursorType.value = CursorType.Basic;
        break;
      default:
        break;
    }
  }
}