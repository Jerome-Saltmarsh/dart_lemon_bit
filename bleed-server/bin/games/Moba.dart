import 'package:lemon_math/give_or_take.dart';

import '../classes/Game.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../common/CharacterType.dart';
import '../common/GameEventType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/classes/Vector2.dart';
import '../instances/scenes.dart';
import '../language.dart';

typedef Players = List<Player>;

final int _framesPerCreepSpawn = 500;
final int _creepsPerSpawn = 5;

class Moba extends Game {
  final Vector2 top = Vector2(0, 50);
  final Vector2 left = Vector2(-600, 620);
  final Vector2 right = Vector2(800, 900);

  final Vector2 teamSpawnWest = Vector2(-600, 620);
  final Vector2 teamSpawnEast = Vector2(850, 910);
  final Vector2 creepSpawn1 = Vector2(-530, 625);
  final Vector2 creepSpawnEast = Vector2(800, 900);

  late List<Vector2> creepWestObjectives;
  late List<Vector2> creepEastObjectives;

  int get totalPlayersRequired => teamSize * numberOfTeams;
  int teamLivesWest = 10;
  int teamLivesEast = 10;

  Moba() : super(
      scenes.wildernessNorth01,
      status: GameStatus.Awaiting_Players,
      gameType: GameType.Moba
  ) {
    creepWestObjectives = [right, top, left];
    creepEastObjectives = [left, top, right];
    teamSize = 2;
    numberOfTeams = 2;
  }

  @override
  void update() {
    if (duration % _framesPerCreepSpawn == 0) {
      spawnCreeps();
    }
  }

  void spawnCreeps() {
    for (int i = 0; i < _creepsPerSpawn; i++) {
      spawnZombie(creepSpawn1.x, creepSpawn1.y,
          health: 100,
          experience: 10,
          objectives: copy(creepWestObjectives),
          team: teams.west);

      spawnZombie(
        creepSpawnEast.x,
        creepSpawnEast.y,
        health: 100,
        experience: 10,
        objectives: copy(creepEastObjectives),
        team: teams.east,
      );
    }
  }

  @override
  onNpcObjectivesCompleted(Npc npc) {
    if (!inProgress) return;
    setCharacterStateDead(npc);
    dispatch(GameEventType.Objective_Reached, npc.x, npc.y);
    if (npc.team == teams.west) {
      teamLivesEast--;
      if (teamLivesEast <= 0) {
        status = GameStatus.Finished;
      }
    } else {
      teamLivesWest--;
      if (teamLivesWest <= 0) {
        status = GameStatus.Finished;
      }
    }
  }

  int getJoinTeam() {
    int totalGood = 0;
    int totalBad = 0;
    for (Player player in players) {
      if (player.team == teams.west) {
        totalGood++;
      } else {
        totalBad++;
      }
    }
    return totalGood > totalBad ? teams.east : teams.west;
  }

  @override
  void onPlayerDisconnected(Player player) {}

  @override
  void onGameStarted() {
    for (Player player in players) {
      if (player.team == teams.west) {
        player.x = teamSpawnWest.x += giveOrTake(5);
        player.y = teamSpawnWest.y += giveOrTake(5);
      } else {
        player.x = teamSpawnEast.x += giveOrTake(5);
        player.y = teamSpawnEast.y += giveOrTake(5);
      }
    }
  }

  Player playerJoin() {
    final Player player = Player(
      x: 0,
      y: 600,
      game: this,
      team: getJoinTeam(),
      type: CharacterType.None,
    );
    if (players.length == totalPlayersRequired){
      status = GameStatus.In_Progress;
      onGameStarted();
    }
    return player;
  }

}


