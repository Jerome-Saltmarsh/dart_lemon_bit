import '../classes.dart';
import '../enums/Weapons.dart';
import '../instances/settings.dart';
import '../settings.dart';
import 'Inventory.dart';

class Player extends Character {
  final String uuid;
  int lastEventFrame = 0;
  int stamina = 0;
  int maxStamina = 200;
  Inventory inventory;
  int grenades;
  int handgunRounds = 0;
  int shotgunRounds = 0;
  int meds;
  int lives;

  Player({
    required this.uuid,
    required double x,
    required double y,
    required this.inventory,
    required String name,
    this.grenades = 0,
    this.meds = 0,
    this.lives = 0
  }) : super(
            x: x,
            y: y,
            weapon: Weapon.HandGun,
            health: settingsPlayerStartHealth,
            maxHealth: settingsPlayerStartHealth,
            speed: playerSpeed,
            name: name) {
    stamina = maxStamina;
    handgunRounds = settings.handgunClipSize;
  }
}
