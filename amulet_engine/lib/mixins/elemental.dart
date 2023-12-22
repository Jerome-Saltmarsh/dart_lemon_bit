
import '../src.dart';

mixin Elemental {
  // red
  var elementFire = 0;
  // green
  var elementElectricity = 0;
  // blue
  var elementWater = 0;

  int get r  => elementFire;
  int get g  => elementElectricity;
  int get b => elementWater;

  int get hue => getHue(
      r,
      g,
      b,
  );

  double get saturation => (r + g + b) / 100.0;

  int getLevelForAmuletItem(AmuletItem amuletItem) =>
      amuletItem.getLevel(
        fire: elementFire,
        water: elementWater,
        electricity: elementElectricity,
      );

  void refillItemSlot(AmuletItemSlot itemSlot){
    final amuletItem = itemSlot.amuletItem;
    if (amuletItem == null) {
      return;
    }
    final itemStats = getAmuletItemStatsForItemSlot(itemSlot);
    if (itemStats == null) {
      itemSlot.max = 0;
      itemSlot.charges = 0;
      itemSlot.cooldown = 0;
      itemSlot.cooldownDuration = 0;
      return;
    }
    final max = itemStats.charges;
    itemSlot.max = max;
    itemSlot.charges = max;
    itemSlot.cooldown = 0;
    itemSlot.cooldownDuration = itemStats.cooldown;
  }

  AmuletItemStats? getAmuletItemStatsForItemSlot(AmuletItemSlot itemSlot) {
    final amuletItem = itemSlot.amuletItem;
    if (amuletItem == null){
      return null;
    }
    return getAmuletItemStats(amuletItem);
  }

  AmuletItemStats? getAmuletItemStats(AmuletItem amuletItem) =>
      amuletItem.getStatsForLevel(
          getLevelForAmuletItem(amuletItem)
      );
}