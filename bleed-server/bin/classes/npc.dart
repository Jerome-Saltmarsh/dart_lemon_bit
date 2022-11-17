import '../common/src/character_type.dart';
import 'game.dart';
import 'player.dart';
import 'ai.dart';

class Npc extends AI {
  final String name;

  Function(Player player)? onInteractedWith;

  Npc({
      required this.name,
      required double x,
      required double y,
      required double z,
      required int health,
      required int weaponType,
      required Game game,
      required int team,
      this.onInteractedWith,
      double wanderRadius = 0,
  })
      : super(
            x: x,
            y: y,
            z: z,
            health: health,
            weaponType: weaponType,
            team: team,
            wanderRadius: wanderRadius,
  );

  @override
  void write(Player player) {
    player.writeNpc(player, this);
  }

  @override
  int get type => CharacterType.Template;
}
