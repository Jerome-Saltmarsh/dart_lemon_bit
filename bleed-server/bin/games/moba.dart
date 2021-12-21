import 'package:lemon_math/give_or_take.dart';

import '../classes/Game.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../common/CharacterType.dart';
import '../common/classes/Vector2.dart';
import '../instances/scenes.dart';
import '../language.dart';
import 'world.dart';

typedef Players = List<Player>;

class Moba extends Game {

  final Vector2 top = Vector2(0, 50);
  final Vector2 left = Vector2(-600, 620);
  final Vector2 right = Vector2(800, 900);

  Vector2 teamSpawnWest = Vector2(-600, 620);
  Vector2 teamSpawnEast = Vector2(850, 910);
  Vector2 creepSpawn1 = Vector2(-530, 625);
  Vector2 creepSpawnEast = Vector2(800, 900);

  late List<Vector2> creepWestObjectives;
  late List<Vector2> creepEastObjectives;

  int totalPlayersRequired = 2;
  int teamLivesWest = 10;
  int teamLivesEast = 10;

  final int framesPerCreepSpawn = 500;
  final int creepsPerSpawn = 5;

  Moba() : super(scenes.wildernessNorth01, started: false){
    creepWestObjectives = [
      right,
      top,
      left
    ];

    creepEastObjectives = [
      left,
      top,
      right
    ];
  }

  @override
  void update() {
    if (!started) return;
    if (duration % framesPerCreepSpawn == 0) {
      spawnCreeps();
    }
  }

  void spawnCreeps() {
    for(int i = 0; i < creepsPerSpawn; i++){
      spawnZombie(creepSpawn1.x, creepSpawn1.y,
          health: 100,
          experience: 10,
          objectives: copy(creepWestObjectives),
          team: teams.west);

      spawnZombie(
        creepSpawnEast.x, creepSpawnEast.y,
        health: 100,
        experience: 10,
        objectives: copy(creepEastObjectives),
        team: teams.east,
      );
    }
  }

  @override
  onNpcObjectivesCompleted(Npc npc){
    if (npc.team == teams.west){
      teamLivesEast--;
    }else{
      teamLivesWest--;
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
}

Player playerJoin(Moba moba) {
  if (moba.started) {
    throw Exception("Game already started");
  }
  final Player player = Player(x: 0, y: 600, game: moba, team: 1);
  registerPlayer(player);
  player.team = moba.getJoinTeam();
  moba.players.add(player);
  print("player.team = ${player.team}");
  moba.started = moba.players.length == moba.totalPlayersRequired;
  if (moba.started) {
    moba.onGameStarted();
  }
  return player;
}

class Creep extends Npc {
  final List<Vector2> checkpoints = [];

  Creep(double x, double y)
      : super(
            x: x, y: y, type: CharacterType.Zombie, health: 20, experience: 1);
}
