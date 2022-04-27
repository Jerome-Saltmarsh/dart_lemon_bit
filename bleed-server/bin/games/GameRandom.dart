

import 'package:lemon_math/random.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/SlotType.dart';
import '../scene_generator.dart';

class GameRandom extends Game {
  var time = 12 * 60 * 60;
  final int maxPlayers;

  GameRandom({required this.maxPlayers}) : super(
      generateRandomScene(
        rows: 100,
        columns: 100,
        seed: random.nextInt(2000),
      )
  );

  bool get full => players.length >= maxPlayers;

  @override
  void update() {
    time++;
  }

  @override
  int getTime() {
    return time;
  }

  Player spawnPlayer() {
      return Player(
        game: this,
        weapon: SlotType.Empty,
        x: 500,
        y: 500,
      );
  }
}