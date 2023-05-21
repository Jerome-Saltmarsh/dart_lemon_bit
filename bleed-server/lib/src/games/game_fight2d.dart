
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

class GameFight2D extends Game<GameFight2DPlayer> {

  @override
  Player createPlayer() {
    return GameFight2DPlayer();
  }

  @override
  void customPlayerWrite(GameFight2DPlayer player) {
    // TODO: implement customPlayerWrite
  }

  @override
  void onPlayerUpdateRequestReceived({
    required GameFight2DPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {
    // TODO: implement onPlayerUpdateRequestReceived
  }

  @override
  void removePlayer(GameFight2DPlayer player) {
    // TODO: implement removePlayer
  }

  @override
  void update() {
    // TODO: implement update
  }
}

class GameFight2DPlayer extends Player {
  @override
  // TODO: implement game
  Game<Player> get game => throw UnimplementedError();

}