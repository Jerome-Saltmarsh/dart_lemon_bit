import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_item.dart';
import 'package:gamestream_ws/packages/common/src/isometric/helm_type.dart';

void setItemSlotValue(
    AmuletPlayer player,
    ItemSlot itemSlot,
    AmuletItem? amuletItem,
    int cooldown,
) {
  itemSlot.item = amuletItem;
  itemSlot.cooldown = cooldown;

  final item = itemSlot.item;

  if (itemSlot.slotType == player.equippedHelm){
    player.helmType = item?.subType ?? HelmType.None;
  }
}

