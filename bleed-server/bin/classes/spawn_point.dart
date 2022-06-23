import 'package:lemon_math/library.dart';

import 'game.dart';

class SpawnPoint with Position {
  final Game game;

  SpawnPoint({
    required this.game,
    required double x,
    required double y,
  }) {
    this.x = x;
    this.y = y;
  }
}