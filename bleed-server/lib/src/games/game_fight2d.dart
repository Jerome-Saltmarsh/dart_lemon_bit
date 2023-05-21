
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

class GameFight2D extends Game<GameFight2DPlayer> {
  GameFight2D() : super(gameType: GameType.Fight2D);


  @override
  GameFight2DPlayer createPlayer() {
    final player = GameFight2DPlayer(this);
    return player;
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

  late GameFight2D game;

  GameFight2DPlayer(this.game);

  @override
  void writePlayerGame() {
    // TODO: implement writePlayerGame

  }
}