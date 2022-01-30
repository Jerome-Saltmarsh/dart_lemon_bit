

import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/core/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
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
    print('events.onServerTypeChanged($serverType)');
    storage.saveServerType(serverType);
  }

  void onModeChanged(Mode mode){
    print("_onGameModeChanged($mode)");
    engine.state.drawCanvas = null;
    engine.actions.clearCallbacks();

    switch(mode){

      case Mode.Website:
        engine.state.drawCanvas = null;
        engine.state.drawCanvasAfterUpdate = false;
        break;

      case Mode.Player:
        engine.state.drawCanvas = modules.game.render.render;
        engine.state.drawCanvasAfterUpdate = false;
        modules.isometric.events.register();
        modules.game.events.register();
        engine.registerZoomCameraOnMouseScroll();
        break;

      case Mode.Editor:
        engine.state.drawCanvasAfterUpdate = true;
        engine.state.drawCanvas = editor.render.render;
        modules.isometric.events.register();
        editor.events.onActivated();
        isometric.actions.removeGeneratedEnvironmentObjects();
        modules.game.actions.deregisterPlayKeyboardHandler();
        game.totalZombies.value = 0;
        game.totalProjectiles = 0;
        game.totalNpcs = 0;
        engine.registerZoomCameraOnMouseScroll();
        break;
    }

    engine.actions.redrawCanvas();
  }


  void onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch(connection){
      case Connection.Connected:
        engine.state.drawCanvas = modules.game.render.render;
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
        engine.actions.fullScreenExit();
        core.actions.clearSession();
        engine.actions.clearCallbacks();
        engine.state.drawCanvas = null;
        engine.state.drawCanvasAfterUpdate = true;
        engine.state.cursorType.value = CursorType.Basic;
        modules.game.actions.deregisterPlayKeyboardHandler();
        break;
      default:
        break;
    }
  }
}