import '../classes/Player.dart';
import '../enums/Weapons.dart';

int equippedWeaponRounds(Player player) {
  switch (player.weapon) {
    case Weapon.HandGun:
      return player.rounds.handgun;
    case Weapon.Shotgun:
      return player.rounds.shotgun;
    case Weapon.SniperRifle:
      return player.rounds.sniper;
    case Weapon.MachineGun:
      return player.clips.machineGun;
  }

  return 0;
}

int equippedWeaponClips(Player player) {
  switch (player.weapon) {
    case Weapon.HandGun:
      return player.clips.handgun;
    case Weapon.Shotgun:
      return player.clips.shotgun;
    case Weapon.SniperRifle:
      return player.clips.sniper;
    case Weapon.MachineGun:
      return player.clips.machineGun;
  }
  return 0;
}

class Clips {
  int handgun;
  int shotgun;
  int sniper;
  int machineGun;

  Clips({
    this.handgun = 0,
    this.shotgun = 0,
    this.sniper = 0,
    this.machineGun = 0});
}

class Rounds {
  int handgun;
  int shotgun;
  int sniper;
  int machineGun;

  Rounds({
    this.handgun = 0,
    this.shotgun = 0,
    this.sniper = 0,
    this.machineGun = 0});
}
