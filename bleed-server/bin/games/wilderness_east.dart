
import '../classes/Character.dart';
import '../classes/Game.dart';
import '../instances/scenes.dart';
import 'world.dart';

class WildernessEast extends Game {
  WildernessEast() : super(scenes.wildernessEast);

  @override
  void onKilledBy(Character target, Character by) {
    // TODO: implement onKilledBy
  }

  @override
  void _update() {
    // TODO: implement update
  }

  @override
  int getTime() {
    return worldTime;
  }
}