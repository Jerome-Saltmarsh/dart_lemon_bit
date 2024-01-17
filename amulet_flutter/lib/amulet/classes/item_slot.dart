
import 'package:amulet_engine/packages/common.dart';
import 'package:lemon_watch/src.dart';

class ItemSlot {
  final int index;
  final SlotType slotType;
  final amuletItem = Watch<AmuletItem?>(null);
  final cooldownPercentage = Watch(0.0);
  final charges = Watch(0);
  final max = Watch(0);
  final chargesRemaining = Watch(false);

  ItemSlot({required this.slotType, this.index = 0}) {
    charges.onChanged((charges) {
      chargesRemaining.value = charges > 0;
    });
  }

  bool get isEmpty => amuletItem.value != null;

  bool acceptsDragFrom(ItemSlot src) {

    final srcItem = src.amuletItem.value;

    if (srcItem == null)
      return false;

    switch (slotType){
      case SlotType.Weapon:
        return srcItem.isWeapon;
      case SlotType.Helm:
        return srcItem.isHelm;
      case SlotType.Armor:
        return srcItem.isArmor;
      case SlotType.Shoes:
        return srcItem.isShoes;
    }
  }
}

