
import 'package:bleed_common/library.dart';

class Weapon {
   int type;
   int damage;
   String uuid;

   String get name => ItemType.getName(type);

   Weapon({required this.type, required this.damage, required this.uuid});
}