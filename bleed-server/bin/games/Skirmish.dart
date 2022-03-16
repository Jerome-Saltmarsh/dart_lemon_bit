

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/SlotType.dart';
import '../engine.dart';

class GameSkirmish extends Game {

  final _time = 12 * 60 * 60;

  GameSkirmish() : super(engine.scenes.skirmish);

  @override
  int getTime() {
    return _time;
  }

  Player playerJoin() {
    final player = Player(
      x: 0,
      y: 600,
      game: this,
      team:teams.none,
      weapon: SlotType.Handgun,
    );
    return player;
  }
}