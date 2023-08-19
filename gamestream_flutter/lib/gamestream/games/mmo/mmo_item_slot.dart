
import 'package:gamestream_flutter/library.dart';

class MMOItemSlot {
  final int index;
  final SlotType slotType;
  final item = Watch<MMOItem?>(null);
  final cooldown = Watch(0);

  MMOItemSlot({required this.slotType, required this.index});

  bool get isEmpty => item.value != null;

  bool acceptsDragFrom(MMOItemSlot src){

    final srcItem = src.item.value;

    if (srcItem == null)
      return false;

    switch (slotType){
      case SlotType.Weapons:
        return srcItem.isWeapon;
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
      case SlotType.Items:
        return true;
    }
  }
}

