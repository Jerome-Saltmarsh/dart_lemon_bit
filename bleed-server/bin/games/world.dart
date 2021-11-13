import '../classes/Game.dart';
import '../compile.dart';
import 'cave.dart';
import 'tavern.dart';
import 'town.dart';

// TODO remove global value
int time = 0;

class World {
  late Game town;
  late Game cave;
  late Game tavern;
  late List<Game> games;

  World(){
    town = Town();
    cave = Cave();
    tavern = Tavern();
    games = [town, cave, tavern];
    // TODO Remove Logic from class
    for(Game game in games){
      compileGame(game);
      game.compiledTiles = compileTiles(game.scene.tiles);
      game.compiledEnvironmentObjects = compileEnvironmentObjects(game.scene.environment);
    }
  }
}

