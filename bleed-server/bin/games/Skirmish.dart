

import '../classes/Game.dart';
import '../engine.dart';

class Skirmish extends Game {

  final _time = 12 * 60 * 60;

  Skirmish() : super(engine.scenes.skirmish);

  @override
  int getTime() {
    return _time;
  }
}