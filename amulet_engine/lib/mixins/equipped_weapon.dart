
import '../classes/amulet_item_slot.dart';

mixin EquippedWeapon {
  final itemSlotWeapon = AmuletItemSlot();
  final itemSlotPower = AmuletItemSlot();

  var itemSlotPowerActive = false;
  var activePowerX = 0.0;
  var activePowerY = 0.0;
  var activePowerZ = 0.0;

  AmuletItemSlot get itemSlotActive =>
      itemSlotPowerActive ? itemSlotPower : itemSlotWeapon;

}