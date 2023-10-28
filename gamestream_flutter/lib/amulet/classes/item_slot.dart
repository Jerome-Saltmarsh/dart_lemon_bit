
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_watch/src.dart';

class ItemSlot {
  final int index;
  final SlotType slotType;
  final amuletItem = Watch<AmuletItem?>(null);
  final cooldownPercentage = Watch(0.0);
  final charges = Watch(0);
  final max = Watch(0);
  final chargesRemaining = Watch(false);

  ItemSlot({required this.slotType, required this.index}) {
    charges.onChanged((charges) {
      chargesRemaining.value = charges > 0;
    });
  }

  bool get isEmpty => amuletItem.value != null;

  bool acceptsDragFrom(ItemSlot src){

    final srcItem = src.amuletItem.value;

    if (srcItem == null)
      return false;

    switch (slotType){
      case SlotType.Weapons:
        return srcItem.isWeapon || srcItem.isSpell;
      case SlotType.Treasures:
        return srcItem.isTreasure;
      case SlotType.Equipped_Hand_Left:
        return srcItem.isHand;
      case SlotType.Equipped_Hand_Right:
        return srcItem.isHand;
      case SlotType.Equipped_Helm:
        return srcItem.isHelm;
      case SlotType.Equipped_Body:
        return srcItem.isBody;
      case SlotType.Equipped_Legs:
        return srcItem.isLegs;
      case SlotType.Equipped_Shoes:
        return srcItem.isShoes;
      case SlotType.Items:
        return true;
    }
  }
}

