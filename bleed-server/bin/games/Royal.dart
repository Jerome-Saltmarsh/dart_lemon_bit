import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Weapon.dart';
import '../common/CharacterType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/WeaponType.dart';
import '../common/classes/Vector2.dart';
import '../functions/withinRadius.dart';
import '../instances/scenes.dart';
import '../utils/game_utils.dart';

class Royal extends Game {

  final List<Player> score = [];
  final boundaryRadiusShrinkRate = 0.02;
  double boundaryRadius = 1000;
  Vector2 boundaryCenter = Vector2(0, 0);

  Royal() : super(scenes.royal, gameType: GameType.BATTLE_ROYAL) {
    status = GameStatus.Awaiting_Players;
    teamSize = 1;
    numberOfTeams = 2;
    boundaryCenter = getSceneCenter();
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
    if (players.length >= playersRequired) {
      status = GameStatus.In_Progress;
      onGameStarted();
    }
    return player;
  }

  @override
  void onPlayerDisconnected(Player player) {
    onPlayerDeath(player);
  }

  @override
  void onPlayerDeath(Player player) {
    score.add(player);
    if (numberOfAlivePlayers == 1) {
      status = GameStatus.Finished;
    }
  }

  @override
  int getTime() {
    return calculateTime(hour: 9);
  }

  @override
  void update(){
    boundaryRadius -= boundaryRadiusShrinkRate;
    for (Player player in players) {
      if (player.dead) continue;
      if (withinDeathBoundary(player)) continue;
      setCharacterStateDead(player);
    }
  }

  bool withinDeathBoundary(Vector2 position){
    return withinRadius(position, boundaryCenter, boundaryRadius);
  }
}

void killCharacter(Character character){

}
