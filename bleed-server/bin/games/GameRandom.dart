

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/SlotType.dart';
import '../scene_generator.dart';

class GameRandom extends Game {
  final int maxPlayers;

  GameRandom({required this.maxPlayers}) : super(generateRandomScene());

  bool get full => players.length >= maxPlayers;

  @override
  int getTime() {
    return 12 * 60 * 60;
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