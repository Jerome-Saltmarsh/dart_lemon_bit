import '../classes/Game.dart';
import '../compile.dart';
import 'cave.dart';
import 'tavern.dart';
import 'town.dart';
import 'wilderness_north_01.dart';

// TODO remove global value
int time = 0;

class World {
  late Game town;
  late Game cave;
  late Game tavern;
  late Game wildernessNorth01;
  late List<Game> games;

  World(){
    town = Town();
    cave = Cave();
    tavern = Tavern();
    wildernessNorth01 = WildernessNorth01();
    games = [town, cave, tavern, wildernessNorth01];

    // TODO Remove Logic from class
    town.spawnPoints = [
      SpawnPoint(game: tavern, x: -145, y: 1900),
      SpawnPoint(game: cave, x: -1281, y: 2408),
    ];

    tavern.spawnPoints = [
      SpawnPoint(
        game: town,
        x: 85,
        y: 250,
      )
    ];

    cave.spawnPoints = [
      SpawnPoint(game: town, x: 318, y: 324)
    ];

    for(Game game in games){
      compileGame(game);
      game.compiledTiles = compileTiles(game.scene.tiles);
      game.compiledEnvironmentObjects = compileEnvironmentObjects(game.scene.environment);
    }
  }
}

