

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Scene.dart';

class GameFrontline extends Game {

  GameFrontline(Scene scene) : super(scene);

  @override
  int getTime() {
    return 0;
  }

  @override
  Player spawnPlayer() {
    // TODO: implement spawnPlayer
    throw UnimplementedError();
  }
}