import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

abstract class Game <T extends Player> {
  var playerId = 0;
  final GameType gameType;
  final List<T> players = [];

  Game({required this.gameType}) {
    engine.onGameCreated(this); // fix this
  }

  void update();

  T createPlayer();

  void onPlayerJoined(T t) {

  }

  void onPlayerUpdateRequestReceived({
    required T player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  });

  void writePlayerResponses() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      player.writePlayerGame();
      player.writeByte(ServerResponse.End);
      // player.sendBufferToClient();
    }
  }

  void removeDisconnectedPlayers() {
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.framesSinceClientRequest++ < 300) continue;
      removePlayer(player);
      i--;
      playerLength--;
    }
  }

  void removePlayer(T player);
}

