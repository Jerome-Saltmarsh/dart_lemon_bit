

import '../../packages/isomeric_engine.dart';
import '../amulet_npc.dart';


class AmuletNpcWitch extends AmuletNpc {

  static const level = 12;

  AmuletNpcWitch({
    required super.x,
    required super.y,
    required super.z,
  }) : super(
    health: 30,
    weaponType: WeaponType.Staff,
    weaponRange: 50,
    weaponDamage: 5,
    team: TeamType.Evil,
    name: 'Witch',
    attackDuration: 20,
  ) {
    // elementFire = 0;
    // elementWater = 0;
    // elementAir = 0;
    // elementStone = 0;
    // changeElement(AmuletElement.values.random);
    // itemSlotWeapon.amuletItem = AmuletItem.Weapon_Staff_Wooden;
    // itemSlotPower.amuletItem = AmuletItem.Weapon_Staff_Wooden;
    // weaponType = itemSlotWeapon.amuletItem?.subType ?? WeaponType.Unarmed;
    // refillItemSlot(itemSlotWeapon);
    // refillItemSlot(itemSlotPower);
  }
}