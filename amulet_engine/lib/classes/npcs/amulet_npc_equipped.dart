
import '../../common/src.dart';
import '../src.dart';

class AmuletNpcEquipped extends AmuletNpc {

  AmuletItem? weaponSlot;

  AmuletNpcEquipped({
      required super.health,
      required super.team,
      required super.attackDamage,
      required super.attackRange,
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