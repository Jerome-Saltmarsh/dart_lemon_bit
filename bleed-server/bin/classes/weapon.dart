
import '../common/weapon_type.dart';
import '../functions/generateUUID.dart';

class Weapon {
   var type = 0;
   var damage = 0;
   final uuid = generateUUID();

   Weapon({this.type = WeaponType.Unarmed, this.damage = 1});
}