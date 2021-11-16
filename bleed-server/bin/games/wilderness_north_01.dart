
import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/classes/Vector2.dart';
import '../instances/scenes.dart';

class WildernessNorth01 extends Game {

  WildernessNorth01() : super(scenes.wildernessNorth01, 64);

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    // TODO: implement getSpawnPositionFrom
    throw UnimplementedError();
  }

  @override
  void onKilledBy(Character target, Character by) {
    // TODO: implement onKilledBy
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    // TODO: implement update
  }

  @override
  List<SpawnPoint> buildInternalSpawnPoints() {
    return [];
  }
}