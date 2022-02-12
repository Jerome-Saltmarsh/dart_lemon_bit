import '../common/CharacterType.dart';
import 'Character.dart';
import 'Player.dart';
import 'Weapon.dart';

class InteractableNpc extends Character {
  final String name;

  Function(Player player) onInteractedWith;

  InteractableNpc({
      required this.name,
      required this.onInteractedWith,
      required double x,
      required double y,
      required int health,
        CharacterType type = CharacterType.Soldier,
      AI? ai,
      required Weapon weapon})
      : super(
            type: type,
            x: x,
            y: y,
            ai: ai,
            health: health,
            weapons: [weapon]
  );
}
