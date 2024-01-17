
import '../../packages/isomeric_engine.dart';
import '../src.dart';

class AmuletNpcEquipped extends AmuletNpc {

  AmuletItem? weaponSlot;

  AmuletNpcEquipped({
      required super.health,
      required super.team,
      required super.weaponDamage,
      required super.weaponRange,
      required super.weaponCooldown,
      required super.x,
      required super.y,
      required super.z,
      required super.name,
      required super.attackDuration,
      required AmuletItem weapon,
  }) : super (weaponType: 0);

  @override
  int get weaponType => weaponSlot?.subType ?? WeaponType.Unarmed;
}