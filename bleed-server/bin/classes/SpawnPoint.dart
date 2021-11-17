import 'Game.dart';
import 'Positioned.dart';

class SpawnPoint extends Positioned {
  final Game game;

  SpawnPoint({
    required this.game,
    required double x,
    required double y,
  }) : super(x, y);
}