
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../compile.dart';
import '../instances/scenes.dart';
import 'world.dart';

typedef Players = List<Player>;
typedef Team = List<Player>;

class Moba extends Game {
  bool started = false;

  Players team1 = [];
  Players team2 = [];

  Moba() : super(scenes.wildernessNorth01){
    //
    compiledTiles = compileTiles(scene.tiles);
    compiledEnvironmentObjects = compileEnvironmentObjects(scene.environment);
  }

  @override
  void update() {
    // TODO: implement update
  }

  Players getJoinTeam(){
    return team1.length > team2.length ? team2 : team1;
  }
}

Player playerJoin(Moba moba){
  if (moba.started) {
    throw Exception("Game already started");
  }
  final Player player = Player(x: 0, y: 600, game: moba, team: 1);
  registerPlayer(player);
  moba.getJoinTeam().add(player);
  moba.started = moba.team1.length + moba.team2.length == 10;
  moba.players.add(player);
  return player;
}
