
import '../common/library.dart';
import '../common/weapon_type.dart';
import 'character.dart';
import 'player.dart';
import 'weapon.dart';

class Rat extends Character {

  Rat({
    required int z,
    required int row,
    required int column,
    int health = 3,
    int damage = 1,
  }) : super(
      x: 0,
      y: 0,
      z: 0,
      health: health,
      equippedWeapon: Weapon(type: WeaponType.Unarmed, damage: damage),
  ) {
    indexZ = z;
    indexRow = row;
    indexColumn = column;
  }

  @override
  void write(Player player){
      player.writeRat(this);
  }
}