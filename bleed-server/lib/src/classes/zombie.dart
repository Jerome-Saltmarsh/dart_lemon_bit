

import 'package:bleed_server/gamestream.dart';

class Zombie extends AI {
  Zombie({
    required double x,
    required double y,
    required double z,
    required int health,
    required int damage,
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
      damage: damage,
      speed: 3.0,
  );

  @override
  void write(Player player) {
    player.writeZombie(this);
  }

  @override
  int get type => CharacterType.Zombie;
}