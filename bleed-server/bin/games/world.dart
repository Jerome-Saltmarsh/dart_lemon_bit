import '../classes/Game.dart';
import '../classes/SpawnPoint.dart';
import '../compile.dart';
import 'cave.dart';
import 'wilderness_west_01.dart';
import 'tavern.dart';
import 'town.dart';
import 'wilderness_north_01.dart';

// TODO remove global value
int time = 0;

class World {
  late Game town;
  late Game tavern;
  late Game wildernessWest01;
  late Game wildernessNorth01;
  late Game cave;
  late List<Game> games;

  World(){
    town = Town();
    tavern = Tavern();
    wildernessWest01 = WildernessWest01();
    wildernessNorth01 = WildernessNorth01();
    cave = Cave();
    games = [town, tavern, wildernessWest01, wildernessNorth01, cave];

    // TODO Remove Logic from class
    town.spawnPoints = [
      SpawnPoint(game: tavern, x: -145, y: 1900),
      SpawnPoint(game: wildernessWest01, x: -1281, y: 2408),
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

    wildernessWest01.spawnPoints = [
      SpawnPoint(game: town, x: 318, y: 324)
    ];

    wildernessNorth01.spawnPoints = [
      SpawnPoint(game: town, x: 587, y: 1235)
    ];

    for(Game game in games){
      compileGame(game);
      game.compiledTiles = compileTiles(game.scene.tiles);
      game.compiledEnvironmentObjects = compileEnvironmentObjects(game.scene.environment);
    }
  }
}

