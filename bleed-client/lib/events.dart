import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/functions/cameraCenterPlayer.dart';
import 'package:bleed_client/network.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:lemon_engine/functions/fullscreen_enter.dart';
import 'package:lemon_engine/functions/fullscreen_exit.dart';

import 'common/GameType.dart';

class Events {
  void _onGameTypeChanged(GameType type) {
    print('events.onGameTypeChanged($type)');
    game.clearSession();
    switch (type) {
      case GameType.None:
        break;
      default:
        connectToWebSocketServer(game.serverType.value, type);
        break;
    }
  }

  void _onServerTypeChanged(ServerType serverType) {
    print('events.onServerTypeChanged($serverType)');
    storage.serverType = serverType;
  }

  void _onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch(connection){
      case Connection.Connected:
        sendRequestJoinGame(game.type.value);
        fullScreenEnter();
        break;
      case Connection.Done:
        fullScreenExit();
        game.clearSession();
        break;
      case Connection.Failed_To_Connect:
        fullScreenExit();
        break;
      default:
        break;
    }
  }

  void _onPlayerUuidChanged(String uuid) {
    if (uuid.isNotEmpty) {
      cameraCenterPlayer();
    }
  }

  void _onPlayerAlivedChanged(bool value) {
    if (value) {
      cameraCenterPlayer();
    }
  }

  Events() {
    print("Events()");
    connection.onChanged(_onConnectionChanged);
    game.type.onChanged(_onGameTypeChanged);
    game.serverType.onChanged(_onServerTypeChanged);
    game.player.uuid.onChanged(_onPlayerUuidChanged);
    game.player.alive.onChanged(_onPlayerAlivedChanged);
  }
}
