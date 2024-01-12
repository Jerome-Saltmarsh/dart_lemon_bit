
import '../classes/amulet_item_slot.dart';

mixin Equipment {
  final equippedWeapon = AmuletItemSlot();
  final equippedHelm = AmuletItemSlot();
  final equippedBody = AmuletItemSlot();
  final equippedLegs = AmuletItemSlot();
  final equippedHandLeft = AmuletItemSlot();
  final equippedHandRight = AmuletItemSlot();
  final equippedShoe = AmuletItemSlot();

  late final equipped = [
    equippedWeapon,
    equippedHelm,
    equippedBody,
    equippedLegs,
    equippedHandLeft,
    equippedHandRight,
    equippedShoe,
  ];
}