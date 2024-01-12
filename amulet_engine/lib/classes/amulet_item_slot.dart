

import '../packages/isometric_engine/packages/common/src.dart';

class AmuletItemSlot {
  AmuletItem? amuletItem;
  var cooldown = 0;
  var cooldownDuration = 0;
  var charges = 0;
  var max = 0;

  void swap(AmuletItemSlot that){
    final cacheAmuletItem = amuletItem;
    final cacheCooldown = cooldown;
    final cacheCooldownDuration = cooldownDuration;
    final cacheCharges = charges;
    final cacheMax = max;

    amuletItem = that.amuletItem;
    cooldown = that.cooldown;
    cooldownDuration = that.cooldownDuration;
    charges = that.charges;
    max = that.max;

    that.amuletItem = cacheAmuletItem;
    that.cooldown = cacheCooldown;
    that.cooldownDuration = cacheCooldownDuration;
    that.charges = cacheCharges;
    that.max = cacheMax;
  }

  double get cooldownPercentage {
    final cooldownDuration = this.cooldownDuration;
    if (cooldownDuration <= 0){
      return 1.0;
    }
    return cooldown / cooldownDuration;
  }

  @override
  String toString() => '{'
      'item: $amuletItem, '
      'cooldown: $cooldown, '
      'cooldownDuration: $cooldownDuration, '
      'charges: $charges, '
      'max: $max '
  '}';

  void incrementCooldown(){
    if (charges >= max){
      return;
    }

    cooldown++;
    if (cooldown < cooldownDuration){
      return;
    }

    charges++;
    clearCooldown();
  }

  void clearCooldown() {
    cooldown = 0;
  }

  void clear(){
    clearCooldown();
    amuletItem = null;
    cooldownDuration = 0;
    charges = 0;
    max = 0;
  }

  bool get chargesEmpty => charges <= 0;

  void reduceCharges(){
     if (charges > 0){
       charges--;
     }
  }
}