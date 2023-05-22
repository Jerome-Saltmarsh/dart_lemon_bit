
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:lemon_math/functions/random_between.dart';

class GameFight2D extends Game<GameFight2DPlayer> {
  final List<GameFight2DCharacter> characters = [];

  GameFight2D() : super(gameType: GameType.Fight2D);

  @override
  GameFight2DPlayer createPlayer() {
    final player = GameFight2DPlayer(this);
    player.x = randomBetween(-100, 100);
    player.y = randomBetween(-100, 100);
    characters.add(player);
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
    if (direction != Direction.None) {
      print(direction);
      player.x++;
    }
  }

  @override
  void removePlayer(GameFight2DPlayer player) {
    characters.remove(player);
  }

  @override
  void update() {
    // TODO: implement update
  }
}

class GameFight2DCharacter {
  var state = GameFight2DCharacterState.idle;
  var x = 0.0;
  var y = 0.0;
}

class GameFight2DPlayer extends Player with GameFight2DCharacter {

  late GameFight2D game;

  GameFight2DPlayer(this.game);

  @override
  void writePlayerGame() {
    writeCharacters();
  }

  void writeCharacters() {
    writeByte(ServerResponse.Fight2D);
    writeByte(Fight2DResponse.Characters);
    writeUInt16(game.characters.length);
    for (final character in game.characters) {
      writeByte(character.state);
      writeInt16(character.x.toInt());
      writeInt16(character.y.toInt());
    }
  }
}