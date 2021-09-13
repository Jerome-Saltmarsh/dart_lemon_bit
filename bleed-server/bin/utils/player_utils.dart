import '../classes/Player.dart';
import '../common/Weapons.dart';

int equippedWeaponRounds(Player player) {
  switch (player.weapon) {
    case Weapon.HandGun:
      return player.rounds.handgun;
    case Weapon.Shotgun:
      return player.rounds.shotgun;
    case Weapon.SniperRifle:
      return player.rounds.sniper;
    case Weapon.AssaultRifle:
      return player.rounds.assaultRifle;
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
    case Weapon.AssaultRifle:
      return player.clips.assaultRifle;
  }
  return 0;
}

class Clips {
  int handgun;
  int shotgun;
  int sniper;
  int assaultRifle;

  Clips({
    this.handgun = 0,
    this.shotgun = 0,
    this.sniper = 0,
    this.assaultRifle = 0});
}

class Rounds {
  int handgun;
  int shotgun;
  int sniper;
  int assaultRifle;

  Rounds({
    this.handgun = 0,
    this.shotgun = 0,
    this.sniper = 0,
    this.assaultRifle = 0});
}
