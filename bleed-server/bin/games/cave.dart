
import '../classes/Character.dart';
import '../classes/Game.dart';
import '../instances/scenes.dart';

class Cave extends Game {
  Cave() : super(scenes.cave);

  @override
  void onKilledBy(Character target, Character by) {
    // TODO: implement onKilledBy
  }

  @override
  void update() {
    // TODO: implement update
  }
}