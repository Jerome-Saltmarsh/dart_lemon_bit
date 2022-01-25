import '../common/CharacterType.dart';
import 'Npc.dart';
import 'Player.dart';
import 'Weapon.dart';

class InteractableNpc extends Npc {
  final String name;

  Function(Player player) onInteractedWith;

  InteractableNpc(
      {required this.name,
      required this.onInteractedWith,
      required double x,
      required double y,
      required int health,
        CharacterType type = CharacterType.Human,
      required Weapon weapon})
      : super(
            type: type,
            x: x,
            y: y,
            health: health,
            weapon: weapon
  );
}
