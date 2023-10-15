
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_watch/src.dart';

class ItemSlot {
  final int index;
  final SlotType slotType;
  final amuletItem = Watch<AmuletItem?>(null);
  final cooldown = Watch(0);
  final cooldownDuration = Watch(0);
  final charges = Watch(0);
  final max = Watch(0);

  ItemSlot({required this.slotType, required this.index});

  bool get isEmpty => amuletItem.value != null;

  bool acceptsDragFrom(ItemSlot src){

    final srcItem = src.amuletItem.value;

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
      case SlotType.Equipped_Shoes:
        return srcItem.isShoes;
      case SlotType.Items:
        return true;
    }
  }
}

