

import 'package:amulet_engine/utils/src.dart';

import '../../mixins/src.dart';
import '../../packages/isomeric_engine.dart';
import '../amulet_npc.dart';


class AmuletNpcWitch extends AmuletNpc with EquippedWeapon {

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
    weaponCooldown: 30,
    team: AmuletTeam.Monsters,
    name: 'Witch',
    attackDuration: 20,
  ) {
    elementFire = 0;
    elementWater = 0;
    elementAir = 0;
    elementStone = 0;
    changeElement(AmuletElement.values.random);
    itemSlotWeapon.amuletItem = AmuletItem.Weapon_Staff_Wooden;
    itemSlotPower.amuletItem = AmuletItem.Spell_Fireball;
    weaponType = itemSlotWeapon.amuletItem?.subType ?? WeaponType.Unarmed;
    refillItemSlot(itemSlotWeapon);
    refillItemSlot(itemSlotPower);
  }

  void changeElement(AmuletElement element){
    elementFire = 0;
    elementWater = 0;
    elementAir = 0;
    elementStone = 0;
    switch (element){
      case AmuletElement.fire:
        elementFire = level;
        // characterType = CharacterType.Witch_Fire;
        break;
      case AmuletElement.water:
        elementWater = level;
        // characterType = CharacterType.Witch_Water;
        break;
      case AmuletElement.stone:
        elementStone = level;
        // characterType = CharacterType.Witch_Stone;
        break;
      case AmuletElement.air:
        elementAir = level;
        // characterType = CharacterType.Witch_Air;
        break;
    }
  }
}