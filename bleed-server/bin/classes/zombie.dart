

import '../common/character_type.dart';
import 'ai.dart';
import 'game.dart';
import 'player.dart';
import 'weapon.dart';

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
      weapon: buildWeaponUnarmed(),
      wanderRadius: wanderRadius,
      game: game,
      team: team,
  );

  @override
  void customUpdateAI(Game game) {

  }

  @override
  void write(Player player) {
    player.writeZombie(this);
  }

  @override
  int get type => CharacterType.Zombie;
}