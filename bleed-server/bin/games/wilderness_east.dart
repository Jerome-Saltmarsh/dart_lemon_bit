
import '../classes/Game.dart';
import '../engine.dart';

class WildernessEast extends Game {
  WildernessEast() : super(engine.scenes.wildernessEast);

  @override
  void update() {
    // TODO: implement update
  }

  @override
  int getTime() {
    return 60 * 60 * 12;
  }
}