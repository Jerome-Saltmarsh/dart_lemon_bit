import '../classes/Game.dart';
import '../classes/SpawnPoint.dart';
import 'cave.dart';
import 'tavern.dart';
import 'town.dart';
import 'wilderness_east.dart';
import 'wilderness_north_01.dart';

/// in seconds
// var worldTime = secondsPerHour * 12;

class World {
  late Game town;
  late Game tavern;
  late Game wildernessNorth01;
  late Game cave;
  late Game wildernessEast;

  World(){
    town = Town();
    tavern = Tavern();
    wildernessNorth01 = WildernessNorth01();
    cave = Cave();
    wildernessEast = WildernessEast();

    // TODO Remove Logic from class
    town.spawnPoints = [
      SpawnPoint(game: tavern, x: -145, y: 1900),
      SpawnPoint(game: wildernessNorth01, x: -1234, y: 1236),
      SpawnPoint(game: cave, x: 1300, y: 1310),
    ];

    cave.spawnPoints = [
      SpawnPoint(game: town, x: -618, y: 1000),
    ];

    tavern.spawnPoints = [
      SpawnPoint(
        game: town,
        x: 85,
        y: 250,
      )
    ];

    wildernessNorth01.spawnPoints = [
      SpawnPoint(game: town, x: 587, y: 1235)
    ];

  }
}



