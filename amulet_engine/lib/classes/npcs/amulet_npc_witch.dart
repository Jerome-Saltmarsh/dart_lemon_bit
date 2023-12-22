

import '../../mixins/src.dart';
import '../../packages/isomeric_engine.dart';
import '../amulet_npc.dart';

class AmuletNpcWitch extends AmuletNpc with EquippedWeapon {

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
    updateItemSlots();
  }

  @override
  int get weaponType =>
      itemSlotWeapon.amuletItem?.subType ?? WeaponType.Unarmed;
}