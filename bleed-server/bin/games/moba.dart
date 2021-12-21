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

  Vector2 teamSpawn1 = Vector2(-600, 620);
  Vector2 teamSpawn2 = Vector2(850, 910);
  Vector2 creepSpawn1 = Vector2(-530, 625);
  Vector2 creepSpawn2 = Vector2(800, 900);

  late List<Vector2> creep1Objectives;
  late List<Vector2> creep2Objectives;

  int totalPlayersRequired = 2;
  int team1Lives = 10;
  int team2Lives = 10;

  final int framesPerCreepSpawn = 300;

  Moba() : super(scenes.wildernessNorth01, started: false){
    creep1Objectives = [
      left,
      top,
      right
    ];

    creep2Objectives = [
      right,
      top,
      left
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
    spawnZombie(creepSpawn1.x, creepSpawn1.y,
        health: 100,
        experience: 10,
        objectives: copy(creep1Objectives),
        team: Teams.Good.index);

    spawnZombie(
      creepSpawn2.x, creepSpawn2.y,
      health: 100,
      experience: 10,
      objectives: copy(creep2Objectives),
      team: Teams.Bad.index,
    );
  }

  int getJoinTeam() {
    int totalGood = 0;
    int totalBad = 0;
    for (Player player in players) {
      if (player.team == Teams.Good.index) {
        totalGood++;
      } else {
        totalBad++;
      }
    }
    return totalGood > totalBad ? Teams.Bad.index : Teams.Good.index;
  }

  @override
  void onPlayerDisconnected(Player player) {}

  @override
  void onGameStarted() {
    for (Player player in players) {
      if (player.team == Teams.Good.index) {
        player.x = teamSpawn1.x += giveOrTake(5);
        player.y = teamSpawn1.y += giveOrTake(5);
      } else {
        player.x = teamSpawn2.x += giveOrTake(5);
        player.y = teamSpawn2.y += giveOrTake(5);
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
