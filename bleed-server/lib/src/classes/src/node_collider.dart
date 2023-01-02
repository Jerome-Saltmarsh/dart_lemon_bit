
import 'package:bleed_server/gamestream.dart';

class InteractableCollider extends GameObject {

  InteractableCollider({required super.x, required super.y, required super.z})
      : super(type: ItemType.GameObjects_Node_Collider) {
    collidable = false;
    physical = false;
    interactable = true;
  }
}