import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/give_or_take.dart';

import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/CharacterType.dart';
import '../common/GameEventType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/SlotType.dart';
import '../instances/scenes.dart';
import '../language.dart';
import '../utilities.dart';

typedef Players = List<Player>;

final int _framesPerCreepSpawn = 500;
final int _creepsPerSpawn = 5;

class GameMoba extends Game {
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

  GameMoba() : super(
      scenes.wildernessNorth01,
      status: GameStatus.Awaiting_Players,
      gameType: GameType.Moba
  ) {
    creepWestObjectives = [right, top, left];
    creepEastObjectives = [left, top, right];
    teamSize = 1;
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
      spawnZombie(
          x: creepSpawn1.x,
          y: creepSpawn1.y,
          health: 100,
          objectives: copy(creepWestObjectives),
          team: teams.west,
          damage: 5
      );

      spawnZombie(
        x: creepSpawnEast.x,
        y: creepSpawnEast.y,
        health: 100,
        objectives: copy(creepEastObjectives),
        team: teams.east,
        damage: 5
      );
    }
  }

  @override
  onNpcObjectivesCompleted(Character character) {
    if (!inProgress) return;
    setCharacterStateDead(character);
    dispatch(GameEventType.Objective_Reached, character.x, character.y);
    if (character.team == teams.west) {
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
    final player = Player(
      x: 0,
      y: 600,
      game: this,
      team: getJoinTeam(),
      weapon: SlotType.Empty,
    );
    if (players.length == totalPlayersRequired){
      status = GameStatus.In_Progress;
      onGameStarted();
    }
    return player;
  }

  @override
  int getTime() {
    return calculateTime(hour: 6);
  }
}






