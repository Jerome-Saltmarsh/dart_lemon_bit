import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/give_or_take.dart';

import '../classes/Crate.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/CharacterType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../functions/withinRadius.dart';
import '../instances/scenes.dart';
import '../update.dart';
import '../utils/game_utils.dart';

class GameRoyal extends Game {

  final List<Player> score = [];
  final boundaryRadiusShrinkRate = 0.02;
  double boundaryRadius = 1000;
  Vector2 boundaryCenter = Vector2(0, 0);

  final time = calculateTime(hour: 9);

  GameRoyal() : super(scenes.royal, gameType: GameType.BATTLE_ROYAL) {
    status = GameStatus.Awaiting_Players;
    teamSize = 1;
    numberOfTeams = 2;
    boundaryCenter = getSceneCenter();

    for(int i = 0; i < 10; i++){
      final crate = Crate(x: giveOrTake(500), y: 500);
      crates.add(crate);
      cratesDirty = true;
    }
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
    if (players.length >= playersRequired) {
      status = GameStatus.Counting_Down;
    }
    return player;
  }

  @override
  void onPlayerDisconnected(Player player) {
    if (inProgress){
      onPlayerDeath(player);
    }else if (countingDown){
      // status = GameStatus.Awaiting_Players;
      // _countDownFrame = _totalCountdownFrames;
    }
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
    return time;
  }

  @override
  void update(){
    if (inProgress) {
      boundaryRadius -= boundaryRadiusShrinkRate;
      for (Player player in players) {
        if (player.dead) continue;
        if (withinDeathBoundary(player)) continue;
        setCharacterStateDead(player);
      }
      return;
    }
  }

  bool withinDeathBoundary(Vector2 position){
    return withinRadius(position, boundaryCenter, boundaryRadius);
  }
}

