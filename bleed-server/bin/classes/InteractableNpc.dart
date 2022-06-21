import '../common/CharacterType.dart';
import 'Player.dart';
import 'ai.dart';

class InteractableNpc extends AI {
  final String name;

  Function(Player player) onInteractedWith;

  InteractableNpc({
      required this.name,
      required this.onInteractedWith,
      required double x,
      required double y,
      required int health,
      required int weapon,
      int team = 1,
  })
      : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            health: health,
            weapon: weapon,
            team: team,
  );
}
