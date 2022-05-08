
import 'package:lemon_math/functions/random_int.dart';

import '../classes/library.dart';
import '../common/ObjectType.dart';
import '../common/TechType.dart';
import '../scene_generator.dart';

/// THEY COME AT NIGHT
/// SURVIVAL HORROR GAME
/// You and a group of others have been ship wrecked on a small paradise island
/// You must explore the island and find and gather up as much resources as possible
/// and bring them back to the camp to prepare for the night
/// At night the monsters come and attack the camp
/// Can you survive until morning?
/// How many days can you and your group survive?
/// Creating a fire costs 100 wood and lasts for a duration before burning out
class GameNightSurvivors extends Game {
  static const spawnStart = 22 * 60 * 60;
  static const spawnEnd = 6 * 60 * 60;
  var time = 12 * 60 * 60;

  late final StaticObject townCenter;

  bool get isFull => players.length >= 5;

  GameNightSurvivors() : super(
      generateRandomScene(
          rows: 200,
          columns: 200,
          seed: randomInt(0, 10000),
          numberOfSpawnPointPlayers: 1,
      )
  ) {
    assert(scene.spawnPointPlayers.isNotEmpty);
    final spawnPoint = scene.spawnPointPlayers.first;
    townCenter = StaticObject(
        x: spawnPoint.x,
        y: spawnPoint.y,
        type: ObjectType.House01
    );
    scene.objectsStatic.add(townCenter);
  }

  Player spawnPlayer() {
     return Player(game: this, weapon: TechType.Unarmed, x: townCenter.x, y: townCenter.y + 100);
  }

  @override
  void update() {
    if (time > spawnStart || time < spawnEnd){
       if (time % 10 == 0) {
         spawnRandomZombie();
       }
    }
    time = (time + 1) % 86400;
  }

  @override
  int getTime() {
    return time;
  }
}