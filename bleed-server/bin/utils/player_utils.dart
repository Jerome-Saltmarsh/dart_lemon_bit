import '../classes/Player.dart';
import '../common/WeaponType.dart';

int equippedWeaponRounds(Player player) {
  switch (player.weapon.type) {
    case WeaponType.HandGun:
      return player.rounds.handgun;
    case WeaponType.Shotgun:
      return player.rounds.shotgun;
    case WeaponType.SniperRifle:
      return player.rounds.sniperRifle;
    case WeaponType.AssaultRifle:
      return player.rounds.assaultRifle;
    default:
      return 0;
  }
}

int equippedWeaponClips(Player player) {
  switch (player.weapon.type) {
    case WeaponType.HandGun:
      return player.clips.handgun;
    case WeaponType.Shotgun:
      return player.clips.shotgun;
    case WeaponType.SniperRifle:
      return player.clips.sniperRifle;
    case WeaponType.AssaultRifle:
      return player.clips.assaultRifle;
    default:
      return 0;
  }
}

class Clips {
  int handgun;
  int shotgun;
  int sniperRifle;
  int assaultRifle;

  Clips({
    this.handgun = 0,
    this.shotgun = 0,
    this.sniperRifle = 0,
    this.assaultRifle = 0});
}

class Rounds {
  int handgun;
  int shotgun;
  int sniperRifle;
  int assaultRifle;

  Rounds({
    this.handgun = 0,
    this.shotgun = 0,
    this.sniperRifle = 0,
    this.assaultRifle = 0});
}
