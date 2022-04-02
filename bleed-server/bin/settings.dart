
import '../bin/common/WeaponType.dart';

final Settings settings = Settings();

_Radius get radius => settings.radius;

_CoolDown get coolDown => settings.coolDown;

_Accuracy get _accuracy => settings.accuracy;

_Range get _range => settings.range;

_ProjectileSpeed _bulletSpeed = settings.projectileSpeed;

double getBulletSpeed(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.HandGun:
      return _bulletSpeed.handgun;
    case WeaponType.Shotgun:
      return _bulletSpeed.shotgun;
    case WeaponType.SniperRifle:
      return _bulletSpeed.sniperRifle;
    case WeaponType.AssaultRifle:
      return _bulletSpeed.assaultRifle;
    default:
      throw Exception("no range found for $weapon");
  }
}

double getWeaponAccuracy(WeaponType weapon){
  switch (weapon){
    case WeaponType.HandGun:
      return _accuracy.handgun;
    case WeaponType.Shotgun:
      return _accuracy.shotgun;
    case WeaponType.SniperRifle:
      return _accuracy.sniperRifle;
    case WeaponType.AssaultRifle:
      return _accuracy.assaultRifle;
    default:
      throw Exception("No accuracy found for $weapon");
  }
}

double getWeaponRange(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.HandGun:
      return _range.handgun;
    case WeaponType.Shotgun:
      return _range.shotgun;
    case WeaponType.SniperRifle:
      return _range.sniperRifle;
    case WeaponType.AssaultRifle:
      return _range.assaultRifle;
    default:
      throw Exception("no range found for $weapon");
  }
}

class Settings {
  final host = '0.0.0.0';
  final port = 8080;

  final _Radius radius = _Radius();
  final _Accuracy accuracy = _Accuracy();
  final _CoolDown coolDown = _CoolDown();
  final _Damage damage = _Damage();
  final _Range range = _Range();
  final _Health health = _Health();
  final _ProjectileSpeed projectileSpeed = _ProjectileSpeed();
  final _Duration duration = _Duration();
  final _NpcSettings npc = _NpcSettings();
  final _MaxClips maxClips = _MaxClips();
  final _Pickup pickup = _Pickup();
  final _ReloadDuration reloadDuration = _ReloadDuration();
  final _PointsEarned pointsEarned = _PointsEarned();
  final double zombieSpeed = 2;
  final double playerSpeed = 4.25;
  final double machineGunBulletSpeed = 18;
  final int crateDeactiveDuration = 1000;
  final double knifeHitAcceleration = 3;
  final double itemCollectRadius = 10;
  final int itemDuration = 500;
  final double grenadeGravity = 0.06;
  final int maxZombies = 2500;
  final int deathMatchMaxPlayers = 32;
  final int itemReactivationInSeconds = 60;
  final int maxGrenades = 3;
  final int maxMeds = 3;
  final int collectCreditAmount = 25;
  final int staminaRefreshRate = 2;
  final int gameStartingCountDown = 400;
  final int casualGameMaxPlayers = 16;

  final double minVelocity = 0.005;
  final double velocityFriction = 0.88;
  final double npcChaseRange = 600;
  final double weaponRangeVariation = 10.0;
  final double playerStartRadius = 50;

  final int shotgunBulletsPerShot = 5;
  final double particleShellSpeed = 3;
  final double bulletImpactVelocityTransfer = 0.25;

  final int generateTilesX = 32;
  final int generateTilesY = 32;

  final int grenadeDuration = 800;
  final double grenadeSpeed = 18;
  final double grenadeFriction = 0.98;
  final double minStamina = 60;
  final int levelUpHealthIncrease = 5;
  final int levelUpMagicIncrease = 5;
}

class _Duration {
  final int strike = 20;
  final int frozen = 60;
}

class _Pickup {
  final int handgun = 10;
  final int shotgun = 5;
  final int sniperRifle = 5;
  final int assaultRifle = 15;
}

class _MaxClips {
  final int handgun = 3;
  final int shotgun = 3;
  final int sniperRifle = 3;
  final int assaultRifle = 3;
}

class _ReloadDuration {
  final int handgun = 20;
  final int shotgun = 20;
  final int sniperRifle = 20;
  final int assaultRifle = 20;
}

class _PointsEarned {
  final int zombieKilled = 5;
  final int zombieHit = 1;
  final int playerKilled = 20;
}

class _Radius {
  final double item = 15;
  final double crate = 22;
  final double character = 10;
  final double interact = 60;
  final double zombieSpawnVariation = 5;
  final double freezeCircle = 40;
  final double explosion = 75;
}

class _Accuracy {
  final double handgun = 0.05;
  final double sniperRifle = 0;
  final double shotgun = 0.15;
  final double assaultRifle = 0.1;
  final double firebolt = 0.1;
}

class _CoolDown {
  final int handgun = 14;
  final int bow = 20;
  final int shotgun = 30;
  final int sniperRifle = 45;
  final int assaultRifle = 5;
  final int clipEmpty = 14;
  final int fireball = 14;
}

class _Damage {
  final int knife = 10;
  final int handgun = 10;
  final int shotgun = 8;
  final int sniperRifle = 35;
  final int assaultRifle = 8;
}

class _Range {
  final double knife = 15;
  final double handgun = 320;
  final double shotgun = 180;
  final double sniperRifle = 600;
  final double assaultRifle = 450;
  final double zombieStrike = 25;
  final double firebolt = 200;
  final double arrow = 300;
  final double slowingCircle = 150;
}

class _ProjectileSpeed {
  final double fireball = 4.0;
  final double handgun = 12.0;
  final double shotgun = 12.0;
  final double sniperRifle = 28;
  final double assaultRifle = 18;
  final double arrow = 7;
}

class _NpcSettings {
  final double destinationRadius = 15.0;
}

class _Health {
  final int player = 100;
  final int zombie = 25;
}

