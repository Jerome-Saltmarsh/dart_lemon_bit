import 'player.dart';
import 'ai.dart';
import 'weapon.dart';

class Npc extends AI {
  final String name;

  Function(Player player)? onInteractedWith;

  Npc({
      required this.name,
      required this.onInteractedWith,
      required double x,
      required double y,
      required double z,
      required int health,
      required Weapon weapon,
      int team = 1,
      double wanderRadius = 0,
  })
      : super(
            x: x,
            y: y,
            z: z,
            health: health,
            weapon: weapon,
            team: team,
            wanderRadius: wanderRadius,
  );

  @override
  void write(Player player) {
    player.writeNpc(player, this);
  }
}
