import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/network.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:neuro/instance.dart';
import 'package:neuro/neuro.dart';

import 'common/GameType.dart';


class GameJoined {}

void dispatch(message) {
  announce(message);
}

void on<T>(HandlerFunction<T> function) {
  neuro.handle(function);
}

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
    sharedPreferences.setInt('server', serverType.index);
  }

  void _onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");
    if (connection == Connection.Connected) {
      sendRequestJoinGame(game.type.value);
    }
  }

  Events(){
    print("Events()");
    connection.onChanged(_onConnectionChanged);
    game.type.onChanged(_onGameTypeChanged);
    game.serverType.onChanged(_onServerTypeChanged);
  }
}
