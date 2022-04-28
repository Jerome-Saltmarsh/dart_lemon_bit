
import '../classes/Game.dart';
import '../common/Shade.dart';
import '../engine.dart';

class Cave extends Game {
  Cave() : super(engine.scenes.cave, shadeMax: Shade.Very_Dark);

  @override
  void update() {
    // TODO: implement update
  }

  @override
  int getTime() {
    return 0;
  }
}