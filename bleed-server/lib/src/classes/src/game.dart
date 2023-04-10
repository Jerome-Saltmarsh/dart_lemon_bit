import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

abstract class Game <T extends Player> {
  var playerId = 0;
  List<T> get players;

  void update();

  /// @override
  void customPlayerWrite(T player);

  Player createPlayer();

  void onPlayerUpdateRequestReceived({
    required T player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  });

  void writePlayerResponses(){
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      player.writePlayerGame();
      customPlayerWrite(player);
      player.writeByte(ServerResponse.End);
      player.sendBufferToClient();
    }
  }
}

