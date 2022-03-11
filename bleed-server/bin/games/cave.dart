
import '../classes/Game.dart';
import '../common/enums/Shade.dart';
import '../engine.dart';
import '../instances/scenes.dart';
import 'world.dart';

class Cave extends Game {
  Cave() : super(engine.scenes.cave, shadeMax: Shade.Very_Dark);

  @override
  void update() {
    // TODO: implement update
  }

  @override
  int getTime() {
    return worldTime;
  }
}