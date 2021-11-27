import '../common/WeaponType.dart';
import 'Npc.dart';
import 'Player.dart';
import 'Weapon.dart';

class InteractableNpc extends Npc {

  final String name;

  Function(Player player) onInteractedWith;

  InteractableNpc({
    required this.name,
    required this.onInteractedWith,
    required double x,
    required double y,
    required int health,
    required Weapon weapon
  }) : super(x: x, y: y, health: health, weapon: weapon);
}
