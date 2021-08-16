import '../classes.dart';
import '../enums/Weapons.dart';
import '../settings.dart';
import 'Ammunition.dart';
import 'Inventory.dart';

class Player extends Character {
  final String uuid;
  final Ammunition handgunAmmunition = Ammunition(8, 8, 3);
  final Ammunition shotgunAmmunition = Ammunition(4, 4, 3);
  int lastEventFrame = 0;
  int stamina = 0;
  int maxStamina = 200;
  Inventory inventory;

  Player(
      {required this.uuid,
        required double x,
        required double y,
        required this.inventory,
        required String name})
      : super(
      x: x,
      y: y,
      weapon: Weapon.HandGun,
      health: settingsPlayerStartHealth,
      maxHealth: settingsPlayerStartHealth,
      speed: playerSpeed,
      name: name){
    stamina = maxStamina;
  }
}
