
import '../packages/isometric_engine/packages/common/src/amulet/amulet_item.dart';

mixin Equipment {
  AmuletItem? equippedWeapon;
  AmuletItem? equippedHelm;
  AmuletItem? equippedArmor;
  AmuletItem? equippedShoes;

  late final equipped = [
    equippedWeapon,
    equippedHelm,
    equippedArmor,
    equippedShoes,
  ];
}