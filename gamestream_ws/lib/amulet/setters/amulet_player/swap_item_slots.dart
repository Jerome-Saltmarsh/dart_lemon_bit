
import 'package:gamestream_ws/amulet.dart';

void swapItemSlots(AmuletPlayer player, ItemSlot a, ItemSlot b){
  final aItem = a.item;
  final aCooldown = a.cooldown;
  final bItem = b.item;
  final bCooldown = b.cooldown;
  a.item = bItem;
  a.cooldown = bCooldown;
  b.item = aItem;
  b.cooldown = aCooldown;
  a.validate();
  b.validate();
  player.notifyEquipmentDirty();
}
