

import '../../mixins/src.dart';
import '../../packages/isomeric_engine.dart';
import '../amulet_item_slot.dart';
import '../amulet_npc.dart';

class AmuletNpcWitch extends AmuletNpc with EquippedWeapon {

  var fireballTimer = 0;

  AmuletNpcWitch({
    required super.x,
    required super.y,
    required super.z,
  }) : super(
    health: 200,
    weaponType: WeaponType.Staff,
    weaponRange: 50,
    weaponDamage: 5,
    weaponCooldown: 30,
    team: AmuletTeam.Monsters,
    name: 'Witch',
    attackDuration: 20,
  ) {
    elementFire = 10;
    elementWater = 10;
    elementElectricity = 10;
    itemSlotWeapon.amuletItem = AmuletItem.Weapon_Staff_Wooden;
    itemSlotPower.amuletItem = AmuletItem.Spell_Fireball;
    refillItemSlot(itemSlotWeapon);
    refillItemSlot(itemSlotPower);
  }

  @override
  void update() {
    super.update();
    itemSlotWeapon.incrementCooldown();
    itemSlotPower.incrementCooldown();
    itemSlotPowerActive = itemSlotPower.charges > 0;

    // itemSlotPowerActive = itemSlotPower.charges > 0;
    // final target = this.target;
    // if (target == null){
    //   return;
    // }
    //
    // final powerItem = itemSlotPower.amuletItem;
    //
    // if (powerItem != null){
    //    final level = powerItem.getLevel(
    //        fire: elementFire,
    //        water: elementWater,
    //        electricity: elementElectricity,
    //    );
    //    if (level != -1){
    //       final stats = powerItem.getStatsForLevel(level);
    //       if (stats != null){
    //         if (withinRadiusPosition(target, stats.range)){
    //           itemSlotPowerActive = true;
    //           setCharacterStateCasting(duration: stats.performDuration);
    //         }
    //       }
    //    }
    // }
  }

  @override
  int get weaponType =>
      itemSlotWeapon.amuletItem?.subType ?? WeaponType.Unarmed;

  void refillItemSlot(AmuletItemSlot itemSlot){
    final amuletItem = itemSlot.amuletItem;
    if (amuletItem == null) {
      return;
    }
    final itemStats = getAmuletItemLevelsForItemSlot(itemSlot);
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

  AmuletItemLevel? getAmuletItemLevelsForItemSlot(AmuletItemSlot itemSlot) {
    final amuletItem = itemSlot.amuletItem;
    if (amuletItem == null){
      return null;
    }
    return getAmuletItemLevel(amuletItem);
  }

  AmuletItemLevel? getAmuletItemLevel(AmuletItem amuletItem) =>
      amuletItem.getStatsForLevel(
          getLevelForAmuletItem(amuletItem)
      );

  int getLevelForAmuletItem(AmuletItem amuletItem) =>
      amuletItem.getLevel(
        fire: elementFire,
        water: elementWater,
        electricity: elementElectricity,
      );
}