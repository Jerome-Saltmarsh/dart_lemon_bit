import '../common/CharacterType.dart';
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
  })
      : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            z: z,
            health: health,
            weapon: weapon,
            team: team,
  );
}
