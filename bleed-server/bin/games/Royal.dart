
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Weapon.dart';
import '../common/CharacterType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/WeaponType.dart';
import '../common/classes/Vector2.dart';
import '../instances/scenes.dart';


class Royal extends Game {

  Royal() : super(scenes.wildernessWest01,
      gameType: GameType.BATTLE_ROYAL
  ){
    status = GameStatus.Awaiting_Players;
    teamSize = 1;
    numberOfTeams = 2;
  }

  int get playersRequired => teamSize * numberOfTeams;

  Player playerJoin() {
    if (status != GameStatus.Awaiting_Players) {
      throw Exception("Game already started");
    }
    Vector2 spawnPoint = getNextSpawnPoint();
    final Player player = Player(
        game: this,
        x: spawnPoint.x,
        y: spawnPoint.y,
        team: -1,
        type: CharacterType.Human,
    );
    player.weapons = [
      Weapon(type: WeaponType.HandGun, damage: 25, capacity: 35),
    ];
    if (players.length >= playersRequired){
      status = GameStatus.In_Progress;
      onGameStarted();
    }
    return player;
  }

  @override
  void update() {
  }
}

