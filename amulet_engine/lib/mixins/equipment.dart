
import '../classes/amulet_item_slot.dart';

mixin Equipment {
  final equippedWeapon = AmuletItemSlot();
  final equippedHelm = AmuletItemSlot();
  final equippedArmor = AmuletItemSlot();
  final equippedShoes = AmuletItemSlot();

  late final equipped = [
    equippedWeapon,
    equippedHelm,
    equippedArmor,
    equippedShoes,
  ];
}