
import '../classes/Game.dart';
import '../instances/scenes.dart';
import 'world.dart';

class WildernessEast extends Game {
  WildernessEast() : super(scenes.wildernessEast);

  @override
  void update() {
    // TODO: implement update
  }

  @override
  int getTime() {
    return worldTime;
  }
}