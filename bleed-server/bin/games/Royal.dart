
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/CharacterType.dart';
import '../common/GameStatus.dart';
import '../common/classes/Vector2.dart';
import '../instances/scenes.dart';
import 'world.dart';


class Royal extends Game {

  int maxPlayers = 2;

  Royal() : super(scenes.wildernessWest01){
    status = GameStatus.Awaiting_Players;
  }

  Player playerJoinMoba() {
    if (status != GameStatus.Awaiting_Players) {
      throw Exception("Game already started");
    }
    Vector2 spawnPoint = getNextSpawnPoint();
    final Player player = Player(
        x: spawnPoint.x,
        y: spawnPoint.y,
        game: this,
        team: -1
    );
    player.type = CharacterType.Human;
    registerPlayer(player);
    players.add(player);
    if (players.length == maxPlayers){
      status = GameStatus.In_Progress;
      onGameStarted();
    }
    return player;
  }

  @override
  void update() {
  }
}

