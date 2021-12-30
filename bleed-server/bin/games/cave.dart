
import '../classes/Character.dart';
import '../classes/Game.dart';
import '../common/enums/Shade.dart';
import '../instances/scenes.dart';
import '../values/world.dart';
import 'world.dart';

class Cave extends Game {
  Cave() : super(scenes.cave, shadeMax: Shade.VeryDark);

  @override
  void onKilledBy(Character target, Character by) {
    // TODO: implement onKilledBy
  }

  @override
  void update() {
    // TODO: implement update
  }

  @override
  int getTime() {
    return worldTime;
  }
}