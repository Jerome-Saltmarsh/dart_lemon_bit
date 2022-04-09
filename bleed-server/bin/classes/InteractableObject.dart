import 'GameObject.dart';
import 'Player.dart';

class InteractableObject extends GameObject {
  Function(Player player) onInteractedWithBy;

  InteractableObject({
    required double x,
    required double y,
    required double radius,
    required this.onInteractedWithBy
  })
      : super(x, y, radius: radius);
}
