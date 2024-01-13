
import '../src.dart';

mixin Elemental {
  var elementFire = 0;
  var elementWater = 0;
  var elementAir = 0;
  var elementStone = 0;

  void refillItemSlot(AmuletItemSlot itemSlot){
    final amuletItem = itemSlot.amuletItem;
    if (amuletItem == null) {
      return;
    }
    // final itemStats = getAmuletItemStatsForItemSlot(itemSlot);
    // if (itemStats == null) {
    //   itemSlot.max = 0;
    //   itemSlot.charges = 0;
    //   itemSlot.cooldown = 0;
    //   itemSlot.cooldownDuration = 0;
    //   return;
    // }
    // final max = itemStats.charges;
    // itemSlot.max = max;
    // itemSlot.charges = max;
    // itemSlot.cooldown = 0;
    // itemSlot.cooldownDuration = itemStats.cooldown;
  }
}