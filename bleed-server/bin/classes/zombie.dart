

import '../common/library.dart';
import 'ai.dart';
import 'game.dart';
import 'player.dart';

class Zombie extends AI {
  Zombie({
    required double x,
    required double y,
    required double z,
    required int health,
    required int damage,
    required Game game,
    required int team,
    double wanderRadius = 100,
  }) : super(
      x: x,
      y: y,
      z: z,
      health: health,
      weaponType: ItemType.Empty,
      wanderRadius: wanderRadius,
      team: team,
  );

  @override
  void write(Player player) {
    player.writeZombie(this);
  }

  @override
  int get type => CharacterType.Zombie;
}