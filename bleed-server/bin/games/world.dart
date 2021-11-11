import '../classes/Game.dart';
import '../compile.dart';
import 'cave.dart';
import 'town.dart';

class World {
  late Game town;
  late Game cave;
  late List<Game> games;

  World(){
    town = Town(this);
    cave = Cave(this);
    games = [town, cave];
    // TODO Remove Logic
    for(Game game in games){
      compileGame(game);
      game.compiledTiles = compileTiles(game.scene.tiles);
      game.compiledEnvironmentObjects = compileEnvironmentObjects(game.scene.environment);
    }
  }
}

