import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/network.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:neuro/instance.dart';
import 'package:neuro/neuro.dart';

import 'common/GameType.dart';

class LobbyJoined {}

class GameJoined {}

void dispatch(message) {
  announce(message);
}

void on<T>(HandlerFunction<T> function) {
  neuro.handle(function);
}

final _Events events = _Events();

class _Events {
  void onGameTypeChanged(GameType type) {
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

  void onServerTypeChanged(ServerType serverType) {
    print('events.onServerTypeChanged($serverType)');
    sharedPreferences.setInt('server', serverType.index);
  }
}
