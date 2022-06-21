import 'collider.dart';
import 'Player.dart';

class InteractableObject extends Collider {
  Function(Player player) onInteractedWithBy;

  InteractableObject({
    required double x,
    required double y,
    required double radius,
    required this.onInteractedWithBy
  })
      : super(x: x, y: y, radius: radius);
}
