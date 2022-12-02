

import 'package:bleed_server/gamestream.dart';

class Zombie extends AI {
  Zombie({
    required int health,
    required int damage,
    required int team,
    double wanderRadius = 100,
    double x = 0,
    double y = 0,
    double z = 0,
  }) : super(
      characterType: CharacterType.Zombie,
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

  // @override
  // void write(Player player) {
  //   player.writeCharacterZombie(this);
  // }
  //
  // @override
  // int get type => CharacterType.Zombie;
}