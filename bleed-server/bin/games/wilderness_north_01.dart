
import '../classes/Game.dart';
import '../engine.dart';

class WildernessNorth01 extends Game {

  WildernessNorth01() : super(engine.scenes.wildernessNorth01);

  @override
  void update() {
    // TODO: implement update
  }

  @override
  int getTime() {
    return 12 * 60 * 60;
  }
}