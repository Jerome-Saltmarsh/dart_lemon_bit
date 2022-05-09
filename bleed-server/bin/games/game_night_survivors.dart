
import 'package:lemon_math/functions/random_int.dart';

import '../classes/library.dart';
import '../common/library.dart';
import '../scene_generator.dart';

/// THEY COME AT NIGHT
/// THE CURSED ISLAND
/// SURVIVAL ADVENTURE HORROR GAME
/// You and a band of others have been ship wrecked on a small paradise island
/// You must explore the island and find and gather up as much resources as possible
/// and bring them back to the camp to prepare for the night
/// At night the monsters come and attack the camp
/// Can you survive until morning?
/// How many days can you and your group survive?
/// Creating a fire costs 100 wood and lasts for a duration before burning out
class GameNightSurvivors extends Game {
  static const playerTeam = 1;
  static const spawnStart = 15 * 60 * 60;
  static const spawnEnd = 6 * 60 * 60;
  var time = 12 * 60 * 60;

  bool spawnMode = false;

  late final Structure townCenter;

  bool get isFull => players.length >= 5;

  GameNightSurvivors() : super(
      generateRandomScene(
          rows: 230,
          columns: 230,
          seed: randomInt(0, 10000),
          numberOfSpawnPointPlayers: 1,
      )
  ) {
    assert(scene.spawnPointPlayers.isNotEmpty);
    final spawnPoint = scene.spawnPointPlayers.first;
    townCenter = Structure (
        team: playerTeam,
        x: spawnPoint.x,
        y: spawnPoint.y,
        type: StructureType.House,
        health: 100,
    );
    structures.add(townCenter);
  }

  Player spawnPlayer() {
     return Player(game: this, weapon: TechType.Unarmed, x: townCenter.x, y: townCenter.y + 100);
  }

  @override
  void update() {
    if (time > spawnStart || time < spawnEnd) {
      if (!spawnMode) {
        spawnMode = true;
        onSpawnModeStarted();
      }
      if (time % 10 == 0) {
        final zombie = spawnRandomZombie();
        zombie.objective = townCenter;
      }
    } else {
      if (spawnMode) {
        spawnMode = false;
        onSpawnModeEnded();
      }
    }
    // if (time % 10 == 0) {
    //   spawnMonster();
    // }
    time = (time + 1) % 86400;
  }

  void spawnMonster(){
    final zombie = spawnRandomZombie();
    zombie.objective = townCenter;
  }

  void onSpawnModeStarted(){

  }

  void onSpawnModeEnded(){

  }

  @override
  int getTime() {
    return time;
  }
}