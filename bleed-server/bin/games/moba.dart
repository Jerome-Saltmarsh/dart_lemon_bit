import 'package:lemon_math/give_or_take.dart';

import '../classes/Game.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../common/CharacterType.dart';
import '../common/classes/Vector2.dart';
import '../compile.dart';
import '../instances/scenes.dart';
import 'world.dart';

typedef Players = List<Player>;
typedef Creeps = List<Creep>;

class Moba extends Game {
  Players players1 = [];
  Players players2 = [];
  Creeps creeps1 = [];
  Creeps creeps2 = [];
  Vector2 teamSpawn1 = Vector2(-600, 620);
  Vector2 teamSpawn2 = Vector2(850, 910);
  Vector2 creepSpawn1 = Vector2(-530, 625);
  Vector2 creepSpawn2 = Vector2(800, 900);

  int totalPlayersRequired = 2;
  int team1Lives = 10;
  int team2Lives = 10;

  Moba() : super(scenes.wildernessNorth01, started: false);

  @override
  void update() {
    if (!started) return;
    if (duration % 300 == 0) {
      spawnZombie(creepSpawn1.x, creepSpawn1.y, health: 10, experience: 10);
      // spawnZombie(creepSpawn2.y, creepSpawn2.y, health: 10, experience: 10);
    }
    //
    // if (duration % 5 == 0){
    // }

    for(Creep creep in creeps1) {
       if (!creep.targetSet){
         // creep.pa
       }
    }
  }

  Players getJoinTeam() {
    return players1.length > players2.length ? players2 : players1;
  }

  @override
  void onPlayerDisconnected(Player player){
    players1.remove(player);
    players2.remove(player);
  }

  @override
  void onGameStarted(){
    for(Player player in players1){
      player.x = teamSpawn1.x += giveOrTake(5);
      player.y = teamSpawn1.y += giveOrTake(5);
    }
    for(Player player in players2){
      player.x = teamSpawn2.x += giveOrTake(5);
      player.y = teamSpawn2.y += giveOrTake(5);
    }
  }
}

Player playerJoin(Moba moba) {
  if (moba.started) {
    throw Exception("Game already started");
  }
  final Player player = Player(x: 0, y: 600, game: moba, team: 1);
  registerPlayer(player);
  moba.getJoinTeam().add(player);
  moba.started = moba.players1.length + moba.players2.length == moba.totalPlayersRequired;
  if (moba.started){
    moba.onGameStarted();
  }
  moba.players.add(player);
  return player;
}

class Creep extends Npc {

  final List<Vector2> checkpoints = [];

  Creep(double x, double y) : super(
      x: x,
      y: y,
      type: CharacterType.Zombie,
      health: 20, experience: 1
  );
}
