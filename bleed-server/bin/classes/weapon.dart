
import '../common/weapon_type.dart';

class Weapon {
   var type = 0;
   var damage = 0;

   Weapon({this.type = WeaponType.Unarmed, this.damage = 1});
}