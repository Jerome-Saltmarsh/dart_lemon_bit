
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Scene.dart';
import '../common/classes/Vector2.dart';
import 'world.dart';

class Tavern extends Game {

  Tavern(Scene scene, int maxPlayers) : super(scene, maxPlayers);

  @override
  Player doSpawnPlayer() {
    // TODO: implement doSpawnPlayer
    throw UnimplementedError();
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    // TODO: implement getSpawnPositionFrom
    throw UnimplementedError();
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    // TODO: implement update
  }
}