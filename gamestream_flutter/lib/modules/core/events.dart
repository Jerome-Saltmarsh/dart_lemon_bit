

import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/gamestream.dart';
import 'package:gamestream_flutter/isometric/events/on_connection_done.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric_web/register_isometric_web_controls.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/classes/websocket.dart';
import 'package:gamestream_flutter/network/instance/websocket.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/website/build_layout_website.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';

import 'exceptions.dart';

class CoreEvents {

  late final CoreState state;

  CoreEvents(this.state){
    state.region.onChanged(_onServerTypeChanged);
    state.account.onChanged(_onAccountChanged);
    webSocket.connection.onChanged(onConnectionChanged);
    sub(_onLoginException);
  }


  Future _onLoginException(LoginException error) async {
    print("onLoginException()");

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
    storage.saveServerType(serverType);
  }

  void onConnectionChanged(Connection connection) {
    switch (connection) {
      case Connection.Connected:
        Engine.onDrawCanvas = modules.game.render.renderGame;
        Engine.onDrawForeground = modules.game.render.renderForeground;
        Engine.onUpdate = modules.game.update.update;
        Engine.drawCanvasAfterUpdate = true;
        modules.game.events.register();
        Engine.zoomOnScroll = true;
        isometricWebControlsRegister();
        Engine.fullScreenEnter();
        break;

      case Connection.Done:
        onConnectionDone();
        isometricWebControlsDeregister();
        Engine.onUpdate = null;
        Engine.fullScreenExit();
        gamestream.clearGameState();
        Engine.drawCanvasAfterUpdate = true;
        Engine.cursorType.value = CursorType.Basic;
        gamestream.gameType.value = null;
        Engine.drawCanvasAfterUpdate = true;
        Engine.onDrawCanvas = Website.renderCanvas;
        Engine.onUpdate = Website.update;
        sceneEditable.value = false;
        break;
      default:
        break;
    }
  }
}

void onChangedRegion(Region region){
  print("onChangedRegion(${region.name})");
  setDialogVisibleCustomRegion(region == Region.Custom);
}

void setDialogVisibleCustomRegion(bool value){
  isVisibleDialogCustomRegion.value = value;
}

void setRegion(Region value){
  core.state.region.value = value;
}
