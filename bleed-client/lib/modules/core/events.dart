

import 'package:bleed_client/actions.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/functions/fullscreen_exit.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/cursor.dart';

class CoreEvents {
  void onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch(connection){
      case Connection.Connected:
        ui.drawCanvasAfterUpdate = false;
        if (game.type.value == GameType.Custom){
          final account = core.state.account.value;
          if (account == null){
            actions.showErrorMessage("Account required to play custom map");
            return;
          }
          final mapName = game.customGameName;
          if (mapName == null){
            actions.showErrorMessage("No custom map chosen");
            actions.disconnect();
            return;
          }
          sendRequestJoinCustomGame(mapName: mapName, playerId: account.userId);
        }else{
          sendRequestJoinGame(game.type.value, playerId: core.state.account.value?.userId);
        }

        engine.callbacks.onLeftClicked = performPrimaryAction;
        engine.callbacks.onPanStarted = performPrimaryAction;
        engine.callbacks.onLongLeftClicked = performPrimaryAction;
        registerPlayKeyboardHandler();
        break;
      case Connection.Done:
        fullScreenExit();
        actions.clearSession();
        engine.callbacks.onLeftClicked = null;
        engine.callbacks.onPanStarted = null;
        engine.callbacks.onLongLeftClicked = null;
        ui.drawCanvasAfterUpdate = true;
        cursorType.value = CursorType.Basic;
        deregisterPlayKeyboardHandler();
        break;
      default:
        break;
    }
  }

}