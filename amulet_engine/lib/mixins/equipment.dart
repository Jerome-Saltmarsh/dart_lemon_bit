
import '../classes/amulet_item_slot.dart';

mixin Equipment {
  final equippedWeapon = AmuletItemSlot();
  final equippedHelm = AmuletItemSlot();
  final equippedArmor = AmuletItemSlot();
  // final equippedLegs = AmuletItemSlot();
  // final equippedHandLeft = AmuletItemSlot();
  // final equippedHandRight = AmuletItemSlot();
  final equippedShoes = AmuletItemSlot();

  late final equipped = [
    equippedWeapon,
    equippedHelm,
    equippedArmor,
    // equippedLegs,
    // equippedHandLeft,
    // equippedHandRight,
    equippedShoes,
  ];
}