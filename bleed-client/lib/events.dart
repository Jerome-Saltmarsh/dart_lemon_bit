
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/functions/cameraCenterPlayer.dart';
import 'package:bleed_client/functions/removeGeneratedEnvironmentObjects.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/modules/website/enums.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';

import 'common/GameType.dart';
import 'enums/Region.dart';
import 'modules/core/enums.dart';

class Events {

  Events() {
    print("Events()");
    webSocket.connection.onChanged(core.events.onConnectionChanged);
    game.type.onChanged(_onGameTypeChanged);
    core.state.region.onChanged(_onServerTypeChanged);
    game.player.uuid.onChanged(_onPlayerUuidChanged);
    game.player.alive.onChanged(_onPlayerAliveChanged);
    game.status.onChanged(_onGameStatusChanged);
    core.state.account.onChanged(_onAccountChanged);
    website.state.dialog.onChanged(_onGameDialogChanged);
    game.player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    core.state.error.onChanged(_onErrorMessageChanged);
    sub(_onGameError);
    sub(_onLoginException);
  }

  void _onErrorMessageChanged(String? message){
    print("onErrorMessageChanged('$message')");
  }

  void _onPlayerCharacterTypeChanged(CharacterType characterType){
    print("events.onCharacterTypeChanged($characterType)");
    if (characterType == CharacterType.Human){
      engine.state.cursorType.value = CursorType.Precise;
    }else{
      engine.state.cursorType.value = CursorType.Basic;
    }
  }

  void _onGameDialogChanged(WebsiteDialog value){
    print("onGameDialogChanged(${enumString(value)})");
  }

  Future _onLoginException(LoginException error) async {
    print("onLoginException()");

    core.actions.logout();

    Future.delayed(Duration(seconds: 1), (){
      // game.dialog.value = Dialogs.Login_Error;
      core.state.error.value = error.cause.toString();
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

  void _onGameTypeChanged(GameType type) {
    print('events.onGameTypeChanged($type)');
    core.actions.clearSession();
    engine.state.camera.x = 0;
    engine.state.camera.y = 0;
    engine.state.zoom = 1;
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

class LoginException implements Exception {
  final Exception cause;
  LoginException(this.cause);
}

