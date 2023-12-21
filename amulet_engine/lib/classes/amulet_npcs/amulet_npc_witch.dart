

import '../../mixins/src.dart';
import '../../packages/isomeric_engine.dart';
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
    itemSlotActive.amuletItem = AmuletItem.Spell_Fireball;
  }

  @override
  void update() {
    super.update();
    if (fireballTimer-- <= 0) {
      itemSlotPowerActive = !itemSlotPowerActive;
      fireballTimer = 300;
    }
  }
}