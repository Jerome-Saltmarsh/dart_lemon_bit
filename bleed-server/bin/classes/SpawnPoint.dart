import '../common/classes/Vector2.dart';
import 'Game.dart';

class SpawnPoint extends Vector2 {
  final Game game;

  SpawnPoint({
    required this.game,
    required double x,
    required double y,
  }) : super(x, y);
}