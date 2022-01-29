

import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/functions/removeGeneratedEnvironmentObjects.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/core/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';

class CoreEvents {

  late final CoreState state;

  CoreEvents(this.state){
    state.mode.onChanged(onModeChanged);
  }

  void onModeChanged(Mode mode){
    print("_onGameModeChanged($mode)");
    engine.state.drawCanvas = null;
    engine.actions.clearCallbacks();

    switch(mode){

      case Mode.Website:
        engine.state.drawCanvas = null;
        break;
      case Mode.Player:
        engine.state.drawCanvas = modules.game.render.render;
        break;
      case Mode.Editor:
        engine.state.drawCanvas = editor.render.render;
        modules.editor.events.onActivated();
        removeGeneratedEnvironmentObjects();
        deregisterPlayKeyboardHandler();
        game.totalZombies.value = 0;
        game.totalProjectiles = 0;
        game.totalNpcs = 0;
        break;
    }

    engine.actions.redrawCanvas();
  }


  void onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch(connection){
      case Connection.Connected:
        engine.state.drawCanvas = modules.game.render.render;
        engine.state.drawCanvasAfterUpdate = false;
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
        modules.game.events.register();
        break;
      case Connection.Done:
        core.state.mode.value = Mode.Website;
        engine.actions.fullScreenExit();
        core.actions.clearSession();
        engine.actions.clearCallbacks();
        engine.state.drawCanvas = null;
        engine.state.drawCanvasAfterUpdate = true;
        engine.state.cursorType.value = CursorType.Basic;
        deregisterPlayKeyboardHandler();
        break;
      default:
        break;
    }
  }
}